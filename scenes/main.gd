extends Control


const _GENDERS := PoolStringArray(["female", "male"])
const _AGES := PoolStringArray(["adult", "teen", "child"])
const _OPTIONS := PoolStringArray(["body", "head"])
const _PATH := "res://sprites/characters/"
const _PALETTES := "res://sprites/palettes/"
const _AT_REGION := Rect2(0, 0, 16, 32)

const _ItemButton := preload("res://scenes/item_button.tscn")
const _PaletteButton := preload("res://scenes/palette_button.tscn")

var _subdirs := PoolStringArray()
var _images := {}
var _cur_gender := 0
var _cur_age := 0
var _cur_option := 0

onready var _genders := $Marg/HBox/VBox/Genders
onready var _ages := $Marg/HBox/VBox/Ages
onready var _options := $Marg/HBox/VBox/Options
onready var _grid := $Marg/HBox/VBox/GridPanel/ScrollContainer/Grid
onready var _palette_skin := $Marg/HBox/VBox2/HBox/Skin/VBox/Grid
onready var _palette_hair := $Marg/HBox/VBox2/HBox/Hair/VBox/Grid
onready var _body := $Marg/HBox/VBox2/VBox/SpritePanel/VBox/Center/Body
onready var _head := $Marg/HBox/VBox2/VBox/SpritePanel/VBox/Center/Head
onready var _anim_box := $Marg/HBox/VBox2/VBox/AnimPanel/VBox/HBox
onready var _anim := $Marg/HBox/VBox2/VBox/AnimPanel/VBox/HBox/AnimationPlayer
onready var _file_dialog := $FileDialog
onready var _credits_pop := $CreditsPop
onready var _message := $Message


func _ready() -> void:
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		_define_js()
		
	_anim.play("default")
	
	var dir := Directory.new()
	dir.open(_PATH)
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			_subdirs.append(file_name)
		file_name = dir.get_next()
		
	for subdir in _subdirs:
		var bodies := []
		var heads := []
		var sub_images := [bodies, heads]
		var subpath:String = _PATH + subdir + "/"
		dir.open(subpath)
		dir.list_dir_begin()
		file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".import"):
				if "body" in file_name:
					bodies.append(load(subpath + file_name.replace(".import", "")))
				else:
					heads.append(load(subpath + file_name.replace(".import", "")))
			file_name = dir.get_next()
		_images[subdir] = sub_images
	
	for o in _GENDERS:
		_genders.add_item(o.capitalize())
	for o in _AGES:
		_ages.add_item(o.capitalize())
	for o in _OPTIONS:
		_options.add_item(o.capitalize())
	
	_make_option_items()
	
	dir.open(_PALETTES)
	dir.list_dir_begin()
	file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".import"):
			var t:Texture = load(_PALETTES + file_name.replace(".import", ""))
			var i:Image = t.get_data()
			i.lock()
			var p := _PaletteButton.instance()
			p.get_child(0).color = i.get_pixel(0, 0)
			i.unlock()
			if "skin" in file_name:
				_palette_skin.add_child(p)
			elif "hair" in file_name:
				_palette_hair.add_child(p)
			p.connect("pressed", self, "_on_color_pressed", [t, "skin" in file_name])
		file_name = dir.get_next()
	
	_file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)


func _define_js() -> void:
	JavaScript.eval("""
	var fileName;
	function download(fileName, byte) {
		var buffer = Uint8Array.from(byte);
		var blob = new Blob([buffer], { type: 'image/png'});
		var link = document.createElement('a');
		link.href = window.URL.createObjectURL(blob);
		link.download = fileName;
		link.click();
	};
	""", true)


func _make_option_items() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for image in _images[_AGES[_cur_age] + "_" + _GENDERS[_cur_gender]][_cur_option]:
		var ib := _ItemButton.instance()
		_grid.add_child(ib)
		ib.connect("pressed", self, "_on_item_pressed", [ib])
		var at := AtlasTexture.new()
		at.atlas = image
		at.region = _AT_REGION
		ib.get_child(0).texture = at


func _on_option_selected(i:int, variable:String) -> void:
	set(variable, i)
	_make_option_items()


func _on_item_pressed(ib:Button) -> void:
	match _cur_option:
		0:
			_body.texture = ib.get_child(0).texture.atlas
			for c in _anim_box.get_children():
				if c is CenterContainer:
					c.get_child(0).get_child(0).get_child(0).texture = ib.get_child(0).texture.atlas
		1:
			_head.texture = ib.get_child(0).texture.atlas
			for c in _anim_box.get_children():
				if c is CenterContainer:
					c.get_child(0).get_child(0).get_child(1).texture = ib.get_child(0).texture.atlas


func _on_color_pressed(t:Texture, is_skin:bool) -> void:
	if is_skin:
		_body.material.set_shader_param("replace_skin", t)
	else:
		_body.material.set_shader_param("replace_hair", t)


func _on_save_pressed() -> void:
	if OS.get_name() != "HTML5" or !OS.has_feature("JavaScript"):
		_file_dialog.popup_centered()
	else:
		var image := _get_save_image()
		var file_name := "char_" + str(hash(image)) + ".png"
		if image.save_png("user://export_temp.png"):
			return
		var file := File.new()
		if file.open("user://export_temp.png", File.READ):
			return
		var png_data := Array(file.get_buffer(file.get_len()))
		file.close()
		var dir := Directory.new()
		dir.remove("user://export_temp.png")
		JavaScript.eval("download('%s', %s);" % [file_name, str(png_data)], true)
		_show_message()
	

func _get_save_image() -> Image:
	var b:Image = _body.texture.get_data()
	var p_skin:Image = _body.material.get_shader_param("palette_skin").get_data()
	var p_hair:Image = _body.material.get_shader_param("palette_hair").get_data()
	var r_skin:Image = _body.material.get_shader_param("replace_skin").get_data()
	var r_hair:Image = _body.material.get_shader_param("replace_hair").get_data()
	_replace_colors(b, p_skin, p_hair, r_skin, r_hair)
	var h:Image = _head.texture.get_data()
	_replace_colors(h, p_skin, p_hair, r_skin, r_hair)
	b.blend_rect(h, Rect2(0, 0, 112, 32), Vector2(0, 0))
	return b
	

func _replace_colors(i:Image, p_skin:Image, p_hair:Image, r_skin:Image, r_hair:Image) -> void:
	i.lock()
	p_skin.lock()
	p_hair.lock()
	r_skin.lock()
	r_hair.lock()
	for x in i.get_width():
		for y in i.get_height():
			var c := i.get_pixel(x, y)
			if not c.a == 0:
				for j in 5:
					if c.is_equal_approx(p_skin.get_pixel(j, 0)):
						i.set_pixel(x, y, r_skin.get_pixel(j, 0))
						break
					elif c.is_equal_approx(p_hair.get_pixel(j, 0)):
						i.set_pixel(x, y, r_hair.get_pixel(j, 0))
						break
	i.unlock()
	p_skin.unlock()
	p_hair.unlock()
	r_skin.unlock()
	r_hair.unlock()


func _on_file_selected(path: String) -> void:
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var image := _get_save_image()
	image.save_png(path)
	_show_message()

func _on_credits_pressed() -> void:
	_credits_pop.popup_centered()
	

func _show_message():
	_message.popup_centered()
	yield(get_tree().create_timer(2), "timeout")
	_message.hide()
