class_name NSTabsMgr
extends Node

@export var buttons: Array[Control] = []
@export var contents: Array[Control] = []
@export var is_joypad_active: bool = true
@export var hierarchy_layer: int = 1 # 1 or 2

var btn_group: ButtonGroup = ButtonGroup.new()

var _first_real_btn: Button = null

func _ready() -> void:
	for real_btn in buttons:
		if !_first_real_btn:
			_first_real_btn = real_btn
			_first_real_btn.set_pressed_no_signal(true)
		real_btn.toggle_mode = true
		real_btn.button_group = btn_group
		(real_btn as Button).toggled.connect(flush_view_visibility.call_deferred)
	flush_view_visibility(true)

var _cached_active_index: int = -99
func flush_view_visibility(is_pressed: bool) -> void:
	if !is_pressed:
		return
	print('flush_view_visibility()')
	var real_btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(real_btn)
	var is_changed: bool = _cached_active_index != active_index
	_cached_active_index = active_index
	print('is_changed = ')
	print(is_changed)
	if is_changed || true:
		for view in contents:
			(view as Control).visible = contents.find(view) == _cached_active_index


## TODO: Listen to game controller L1/R1
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("gc_l%d" % hierarchy_layer):
		try_prev_tab()
	if Input.is_action_just_pressed("gc_r%d" % hierarchy_layer):
		try_next_tab()

func try_prev_tab() -> void:
	if !is_joypad_active:
		return
	if _cached_active_index > 0:
		_activate_prev()

func try_next_tab() -> void:
	if !is_joypad_active:
		return
	if _cached_active_index < buttons.size() - 1:
		_activate_next()

func _activate_prev():
	print('func _activate_prev():')
	_activate_another(-1)

func _activate_next():
	print('func _activate_next():')
	_activate_another(1)

func _activate_another(shift: int):
	var real_btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(real_btn)
	active_index += shift
	#_cached_active_index = active_index
	(buttons[active_index] as Button).set_pressed(true)
	flush_view_visibility(true)
