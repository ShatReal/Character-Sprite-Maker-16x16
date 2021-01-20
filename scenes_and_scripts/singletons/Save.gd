extends Node

const IMAGE_SIZE = 16 # pixels
const NUM_FRAMES = 4 # frames 0 and 3 are actually the same frame

# A 2-D array of the original colors of the sprites.
var colors_to_replace = [
	[Color(230.0/255.0, 69.0/255.0, 57.0/255.0, 1), Color(173.0/255.0, 47.0/255.0, 69.0/255.0, 1), Color(120.0/255.0, 29.0/255.0, 79.0/255.0, 1), Color(79.0/255.0, 29.0/255.0, 76.0/255.0, 1)],
	[Color(240.0/255.0, 181.0/255.0, 65.0/255.0, 1), Color(207.0/255.0, 117.0/255.0, 43.0/255.0, 1), Color(171.0/255.0, 81.0/255.0, 48.0/255.0, 1), Color(125.0/255.0, 56.0/255.0, 51.0/255.0, 1)],
	[Color(200.0/255.0, 212.0/255.0, 93.0/255.0, 1), Color(99.0/255.0, 171.0/255.0, 63.0/255.0, 1), Color(59.0/255.0, 125.0/255.0, 79.0/255.0, 1), Color(47.0/255.0, 87.0/255.0, 83.0/255.0, 1)],
	[Color(146.0/255.0, 232.0/255.0, 192.0/255.0, 1), Color(79.0/255.0, 164.0/255.0, 184.0/255.0, 1), Color(76.0/255.0, 104.0/255.0, 133.0/255.0, 1), Color(58.0/255.0, 63.0/255.0, 94.0/255.0, 1)]
]

var layers = []
var paths = []									# Array of the paths to the images on the Front view.
var images = []									# 3-D array of every single image that needs to drawn.
													# images[view][option][frame]
var mtrl_replace_colors = []					# 3-D array of all colors to replace with.
													# mtrl_replace_colors[option][color option][color]
													

func get_img_data():
	for option in Global.previews[0].get_children(): # Front
		if option.texture == null:
			paths.append(null)
		else:
			var path = option.texture.resource_path.split("/", false, 3)[-1].replace("_1.png", "")
			paths.append(path)

func get_images():
	for view in Global.VIEWS:
		var img_views = []
		for path in paths:
			if path:
				var base_path = "res://sprites/" + view + "/" + path
				var frames = []
				frames.append(load(base_path + "_1.png").get_data()) # Frame 0 and 3 are the same
				frames.append(load(base_path + "_0.png").get_data())
				frames.append(frames[0])
				frames.append(load(base_path + "_2.png").get_data())
				img_views.append(frames)
			else:
				img_views.append(null)
		images.append(img_views)

func get_replacement_colors():
	# Since the materials are in reverse draw order I'll iterate through them in reverse
	for i in range(Global.NUM_OPTIONS-1, -1, -1):
		var color_options = []
		for j in range(Global.NUM_COLORS):
			var replace_color_set = []
			var curr_color = Global.materials[i].get_shader_param("REPLACE" + "_" + str(j) + "_0")
			replace_color_set.append(curr_color)
			replace_color_set.append(curr_color.darkened(.15))
			replace_color_set.append(curr_color.darkened(.30))
			replace_color_set.append(curr_color.darkened(.45))
			color_options.append(replace_color_set)
		mtrl_replace_colors.append(color_options)

func draw_img(result_img):
	for i in range(images.size()):
		var view = images[i]
		var order
		if i == 2: # The draw order of the items is different for the back view.
			order = [0, 1, 2, 5, 4, 6, 3]
		elif i == 1 or i == 3: # Side view:
			order = [0, 1, 2, 4, 5, 3, 6]
		else: # Front view
			order = [0, 1, 2, 3, 4, 5, 6]
		for j in order:
			var layer = view[j]
			if layer:
				for k in range(NUM_FRAMES):
					var img = layer[k]
					img.lock()
					for x in range(IMAGE_SIZE):
						for y in range(IMAGE_SIZE):
							var color = img.get_pixel(x, y)
							if color.a != 0:
								var outer_index = -1
								var inner_index = -1
								for l in range(Global.NUM_COLORS):
									inner_index = colors_to_replace[l].find(color)
									if inner_index > -1:
										outer_index = l
										break
								if outer_index > -1:
									result_img.set_pixel(IMAGE_SIZE*k + x, IMAGE_SIZE*i + y, mtrl_replace_colors[j][outer_index][inner_index])
					img.unlock()

func save_image():
	var result_img = Image.new()
	result_img.create(IMAGE_SIZE*4, IMAGE_SIZE*4, false, Image.FORMAT_RGBA8)
	result_img.lock()
	get_img_data()
	get_images()
	get_replacement_colors()
	draw_img(result_img)
	result_img.unlock()
	
	# Will save image instead of downloading it
	if OS.get_name() == "HTML5" and OS.has_feature('JavaScript'):
		HTML5File.save_image(result_img, "character_sprite_sheet")
	else:
		result_img.save_png("res://test.png")
	
	paths = []
	images = []
	mtrl_replace_colors = []
