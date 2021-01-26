tool
class_name ColPicker
extends ColorPicker

onready var _mat = preload('./grayscale.material') as Material
onready var _lock := BackBufferCopy.new()
onready var _timer := Timer.new()
onready var _col_lock := ColorRect.new()
onready var _hue_lock := ColorRect.new()
onready var _locker := Control.new()

var mouse_in = false

export(bool) var locked = false setget set_locked

func _ready() -> void:
	var child4 = get_child(4)
	var child4_4 = get_child(4).get_child(4)
	var child0_0 = get_child(0).get_child(0)
	var child0_1 = get_child(0).get_child(1)
	hsv_mode = true
	presets_enabled = false
	presets_visible = false
	get_child(3).hide()
	get_child(1).hide()
	var picker = Button.new()
	picker.name = 'Picker'
	picker.text = 'Pick'
	picker.connect('pressed', self, '_on_picker_pressed', [picker])
	child4_4.add_child(picker)
	picker.size_flags_horizontal = 3
	child4_4.get_child(1).hide()
	child0_0.rect_min_size = Vector2(200, 140)
	child0_1.rect_min_size.x = 16
	for i in range(4):
		var line_edit = child4.get_child(i).get_child(2).get_child(0)
		line_edit.context_menu_enabled = false
		line_edit.caret_blink = true
		line_edit.caret_blink_speed = 0.5
	for i in range(3):
		var h_slider = child4.get_child(i).get_child(1)
		h_slider.margin_right = 160
	for i in range(4):
		var rgba_label = child4.get_child(i).get_child(0)
		rgba_label.rect_min_size.x = 16
	for i in range(4):
		var spin_box = child4.get_child(i).get_child(2)
		spin_box.align = 1
		spin_box.connect('gui_input', self, '_on_gui_input', [spin_box])
		#spin_box.rect_min_size.x = 10
	var hex_line_edit = child4_4.get_child(3)
	hex_line_edit.size_flags_horizontal = 3
	hex_line_edit.align = 1
	hex_line_edit.add_constant_override('minimum_spaces',20)
	hex_line_edit.rect_min_size.x = 50
	hex_line_edit.context_menu_enabled = false
	hex_line_edit.caret_blink = true
	hex_line_edit.caret_blink_speed = 0.5
	var hsv_check_button = child4_4.get_child(0)
	var raw_check_button = child4_4.get_child(1)
	hsv_check_button.enabled_focus_mode = 0
	raw_check_button.enabled_focus_mode = 0
	hsv_check_button.align = 1
	raw_check_button.align = 1
	hsv_check_button.text = "HSV "
	raw_check_button.text = "RAW "
	rect_size = Vector2(100,100)
	child0_0.connect('mouse_entered', self, '_on_ColPicker_mouse_entered')
	child0_0.connect('mouse_exited', self, '_on_ColPicker_mouse_exited')
	child0_1.connect('mouse_entered', self, '_on_ColPicker_mouse_entered')
	child0_1.connect('mouse_exited', self, '_on_ColPicker_mouse_exited')
# warning-ignore:return_value_discarded
	connect('resized', self, '_on_resize', [child0_0, child0_1])
	add_child(_lock)
	_lock.rect.position = rect_position
	_lock.rect.size = rect_size
	_lock.add_child(_col_lock)
	_col_lock.material = _mat
	_lock.add_child(_hue_lock)
	_hue_lock.material = _mat
	_lock.add_child(_locker)
	add_child(_timer)
	_timer.one_shot = true
# warning-ignore:return_value_discarded
	_timer.connect('timeout', self, '_on_timer_timeout', [child0_0, child0_1])
	#get_child(4).move_child(child4_4, 0)
	emit_signal('resized')
	set_locked(false)
	#EG.dprint('ColPickerReady')

func _input(event: InputEvent) -> void:
	if !event is InputEventMouseButton or !mouse_in:
		return
	if event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		if event.button_index == BUTTON_WHEEL_UP:
			color.h -= .0028
		if event.button_index == BUTTON_WHEEL_DOWN:
			color.h += .0028
	else:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CONFINED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func _on_resize(col, hue) -> void:
	if _lock.rect.position != rect_position || _lock.rect.size != rect_size:
		_lock.rect.position = rect_position
		_lock.rect.size = rect_size
	if _locker.rect_position != rect_position || _locker.rect_size != rect_size:
		_locker.rect_position = rect_position
		_locker.rect_size = rect_size
	if _col_lock.rect_position != col.rect_position || _col_lock.rect_size != col.rect_size:
		_col_lock.rect_position = col.rect_position
		_col_lock.rect_size = col.rect_size
	if _hue_lock.rect_position != hue.rect_position || _hue_lock.rect_size != hue.rect_size:
		_hue_lock.rect_position = hue.rect_position
		_hue_lock.rect_size = hue.rect_size
	_timer.start(0.1)

func _on_timer_timeout(col, hue) -> void:
	var _clp = _col_lock.rect_position; var _cp = col.rect_position; var _cls = _col_lock.rect_size; var _cs = col.rect_size
	var _hlp = _hue_lock.rect_position; var _hp = hue.rect_position; var _hls = _hue_lock.rect_size; var _hs = hue.rect_size
	var _lp = _lock.rect.position; var _rp = rect_position; var _ls = _lock.rect.size; var _rs = rect_size
	var lp = _locker.rect_position; var ls = _locker.rect_size
	if _clp == _cp && _cls == _cs && _hlp == _hp && _hls == _hs && _lp == _rp && _ls == _rs && lp == _rp && ls == _rs:
		return
	emit_signal('resized')

func _on_gui_input(event : InputEvent, child : SpinBox) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			child.get_child(0).editable = false
		else:
			child.get_child(0).editable = true

func _on_picker_pressed(_picker : Button):
	get_child(1).get_child(1).emit_signal('pressed')

func _on_ColPicker_mouse_entered() -> void:
	if !mouse_in:
		mouse_in = true

func _on_ColPicker_mouse_exited() -> void:
	if mouse_in:
		mouse_in = false

func set_locked(val : bool) -> void:
	locked = val
	if _lock != null:
		_lock.visible = true if locked else false
