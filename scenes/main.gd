extends MarginContainer


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

onready var _genders := $HBox/VBox/Genders
onready var _ages := $HBox/VBox/Ages
onready var _options := $HBox/VBox/Options
onready var _grid := $HBox/VBox/GridPanel/ScrollContainer/Grid
onready var _palette_skin := $HBox/VBox2/HBox/Skin/VBox/Grid
onready var _palette_hair := $HBox/VBox2/HBox/Hair/VBox/Grid
onready var _body := $HBox/VBox2/SpritePanel/CenterContainer/Sprites/Body
onready var _head := $HBox/VBox2/SpritePanel/CenterContainer/Sprites/Head
onready var _body_small := $HBox/VBox2/SpritePanel/BodySmall
onready var _head_small := $HBox/VBox2/SpritePanel/HeadSmall
onready var _file_dialog := $Node/FileDialog


func _ready() -> void:
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		_define_js()
	
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
			else:
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
			_body_small.texture = ib.get_child(0).texture.atlas
		1:
			_head.texture = ib.get_child(0).texture.atlas
			_head_small.texture = ib.get_child(0).texture.atlas


func _on_color_pressed(t:Texture, is_skin:bool) -> void:
	if is_skin:
		_body.material.set_shader_param("replace_skin", t)
	else:
		_body.material.set_shader_param("replace_hair", t)


func _on_save_pressed() -> void:
	if OS.get_name() != "HTML5" or !OS.has_feature('JavaScript'):
		_file_dialog.popup_centered()
	else:
		var image := _get_save_image()
		var file_name := str(hash(image)) + ".png"
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
	

func _get_save_image() -> Image:
	var image := get_viewport().get_texture().get_data()
	image.flip_y()
	return image.get_rect(Rect2(_body_small.global_position, _body_small.texture.get_size()))


func _on_file_selected(path: String) -> void:
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var image := _get_save_image()
	image.save_png(path)
