extends Node

# Node variables, initialized in _ready
var options
var items
var remove
var reset
var save
var prev_box
var flip_switch
var color_box
var color_picker

var images = []			# 3D array of all images used in the customizer
var image_names = []	# 3D array of image names
var previews = []
var color_rects = []
var button_groups = []
var materials = []

# Constants
const ScrollClass = preload("res://scenes_and_scripts/scenes/OptionScroll.tscn")
const ItemClass = preload("res://scenes_and_scripts/scenes/Item.tscn")
const VIEWS = ["front", "left", "back", "right"]
const OPTIONS = ["helms", "hair_front", "hair_base", "hair_back", "eyes", "outfits", "base"]
const NUM_VIEWS = 4
const NUM_OPTIONS = 7
const NUM_COLORS = 4
const DEFAULT_COLORS = [
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
	[Color.tan, Color.azure, Color.lightskyblue, Color.lightsalmon],
]

# Customizable variables
var cur_colors
var cur_rect = 0
var cur_option = 0
var flips = [false, false, false, false, false, false, false]

func _ready():
	var main = $"/root/Main"
	options = main.get_node("HBox/ItemDisplay/Options")
	items = main.get_node("HBox/ItemDisplay/ItemPanel/Items")
	remove = main.get_node("HBox/ItemDisplay/Remove")
	reset = main.get_node("HBox/ItemDisplay/Reset")
	save = main.get_node("HBox/ItemDisplay/Save")
	prev_box = main.get_node("HBox/PreviewPanel/PreviewBox")
	flip_switch = main.get_node("HBox/PreviewPanel/PreviewBox/Flipped/Switch")
	color_box = main.get_node("HBox/ColorPanel/ColorBox")
	color_picker = main.get_node("HBox/PickerPanel/ColorPicker")

	main.connect("ready", self, "set_up_main")
	
# Loads all the first frame images at once. This isn't really necessary
# for the images used in this project, but with larger images
# the game will hang if you try to load them when the player
# switches options. Also sets the image_names array.
func load_images():
	var dir = Directory.new()
	for view in VIEWS:
		var view_arr = []
		var names_arr = []
		for option in OPTIONS:
			var option_arr = []
			var names_arr_2 = []
			var path = "res://sprites/" + view + "/" + option + "/"
			dir.open(path)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				# The normal files are gone when the game is exported and only the import
				# files are left but the resource loader takes the normal file paths
				# as an argument
				if not dir.current_is_dir() and file_name.ends_with("_1.png.import"):
					option_arr.append(load(path + file_name.replace(".import", "")))
					names_arr_2.append(file_name.replace("_1.png.import", ""))
				file_name = dir.get_next()
			view_arr.append(option_arr)
			names_arr.append(names_arr_2)
		images.append(view_arr)
		image_names.append(names_arr)

func get_materials():
	for i in range(previews[0].get_child_count()-1, -1, -1):
		materials.append(previews[0].get_child(i).material)

# Makes all of the icons for the options and then hides the ones not in use
func make_icons():
	for i in range(len(images[0])): # Loops through front view images
		var scroll = ScrollClass.instance()
		items.add_child(scroll)
		scroll.material = materials[i]
		var item = ItemClass.instance()
		# ScrollContainers have two children implicitly created (scroll bars)
		scroll.get_child(2).add_child(item)
		var button = item.get_child(0)
		button.connect("pressed", self, "remove_cur_option")
		button.toggle_mode = false
		button.disabled = false
		button.use_parent_material = false
		var group = ButtonGroup.new()
		button_groups.append(group)
		for j in range(len(images[0][i])):
			item = ItemClass.instance()
			scroll.get_child(2).add_child(item)
			button = item.get_child(0)
			button.texture_normal = images[0][i][j]
			button.connect("gui_input", self, "on_item_pressed", [button, j])
			button.group = group
			item.get_child(1).text = image_names[0][i][j].capitalize()
		scroll.hide()
	items.get_child(0).show()

func set_up_main():
	options.connect("item_selected", self, "change_option")
	remove.connect("pressed", self, "remove_all_items")
	reset.connect("pressed", self, "set_default_colors")
	save.connect("pressed", $"/root/Save", "save_image")
	
	load_images()
	
	for i in NUM_VIEWS:
		var preview = prev_box.get_child(i).get_child(1)
		preview.get_node("Base").texture = images[i][6][0] # Sets the "Base" image for the view
		previews.append(preview)
	# Changes node order so that the items are layered properly.
	previews[1].move_child(previews[1].get_node("Hair Back"), 6)
	previews[2].move_child(previews[2].get_node("Hair Back"), 7)
	previews[2].move_child(previews[2].get_node("Hair Base"), 5)
	previews[3].move_child(previews[3].get_node("Hair Back"), 6)
	
	get_materials()
	make_icons()
	
	flip_switch.connect("pressed", self, "on_flip_switch_pressed")
	
	for i in range(color_box.get_child_count()):
		var rect = color_box.get_child(i).get_child(1)
		rect.connect("gui_input", self, "on_rect_selected", [i])
		color_rects.append(rect)
	
	color_picker.connect("color_changed", self, "on_color_changed")

	add_keys()
	set_default_colors()
	
func add_keys():
	for key in OPTIONS:
		options.add_item(key.capitalize())
	
# Sets the shaders and color boxes to white
func set_default_colors():
	var front_view = prev_box.get_node("FrontBox/Front")
	cur_colors = DEFAULT_COLORS.duplicate(true)
	for i in range(NUM_OPTIONS):
		for j in range(NUM_COLORS):
			front_view.get_child(i).material.set_shader_param("REPLACE_" + str(j) + "_0", DEFAULT_COLORS[i][j])
	for i in range(NUM_COLORS):
		color_rects[i].color = DEFAULT_COLORS[cur_option][i]
	color_picker.color = DEFAULT_COLORS[cur_option][cur_rect]

func change_option(new_option):
	# Displays current grid of items
	items.get_child(cur_option).hide()
	items.get_child(new_option).show()
	# Sets flip switch to correct position for the option
	flip_switch.pressed = flips[new_option]
	# Resets the current ColorRect to the first one and changes their colors
	color_rects[cur_rect].rect_min_size = Vector2(32, 32)
	color_rects[0].rect_min_size = Vector2(64, 64)
	for i in range(len(color_rects)):
		color_rects[i].color = cur_colors[new_option][i]
	color_picker.color = color_rects[0].color
	
	cur_option = new_option
	cur_rect = 0

func get_preview_option(preview):
	return preview.get_node(OPTIONS[cur_option].capitalize())

func remove_cur_option():
	for preview in previews:
		get_preview_option(preview).texture = null
	if button_groups[cur_option].get_pressed_button():
		button_groups[cur_option].get_pressed_button().pressed = false

# Since I want pressing an already-selected item to remove it,
# I have disabled the default pressed function and am handling it
# like this
func on_item_pressed(event, button, img_index):
	if event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		if button.pressed:
			button.pressed = false
			remove_cur_option()
		else:
			button.pressed = true
			for i in range(NUM_VIEWS):
				get_preview_option(previews[i]).texture = images[i][cur_option][img_index]

func remove_all_items():
	for preview in previews:
		for option in preview.get_children():
			if option.name != "Base":
				option.texture = null
	for group in button_groups:
		if group.get_pressed_button():
			group.get_pressed_button().pressed = false

func on_flip_switch_pressed():
	flips[cur_option] = !flips[cur_option]
	for preview in previews:
		var cur_option_node = get_preview_option(preview)
		cur_option_node.rect_scale.x *= -1
		if cur_option_node.rect_scale.x < 0:
			cur_option_node.rect_position.x = 64
		else:
			cur_option_node.rect_position.x = 0
	# Swaps Left and Right images
	var temp = get_preview_option(previews[1]).texture
	get_preview_option(previews[1]).texture = get_preview_option(previews[3]).texture
	get_preview_option(previews[3]).texture = temp
	
func on_rect_selected(event, new_rect):
	if event is InputEventMouseButton and event.is_pressed():
		color_rects[cur_rect].rect_min_size = Vector2(32, 32)
		color_rects[new_rect].rect_min_size = Vector2(64, 64)
		color_picker.color = color_rects[new_rect].color
		cur_rect = new_rect

func on_color_changed(new_color):
	color_rects[cur_rect].color = new_color
	cur_colors[cur_option][cur_rect] = new_color
	for preview in previews:
		var cur_option_node = get_preview_option(preview)
		cur_option_node.material.set_shader_param("REPLACE_" + str(cur_rect) + "_0", new_color)
