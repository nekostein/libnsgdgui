class_name NSTabsMgr
extends Node

@export var buttons: Array[Control] = []
@export var contents: Array[Control] = []
@export var contents_enabled: bool = true # If false, ignore contents
@export var is_joypad_active: bool = true
@export var hierarchy_layer: JoypadControlGroup = JoypadControlGroup.L1_R1

@export var disabled_at_start: int = 0
@export var disabled_at_end: int = 0

const _JoypadControlGroup_map: Dictionary = {
	JoypadControlGroup.L1_R1: [&'gc_l1', &'gc_r1'],
	JoypadControlGroup.L2_R2: [&'gc_l2', &'gc_r2'],
	JoypadControlGroup.UP_DOWN: [&'gc_up', &'gc_down'],
	JoypadControlGroup.LEFT_RIGHT: [&'gc_left', &'gc_right'],
}

enum JoypadControlGroup {
	L1_R1,
	L2_R2,
	UP_DOWN,
	LEFT_RIGHT
}

var btn_group: ButtonGroup = ButtonGroup.new()

var _first_real_btn: Button = null

func _ready() -> void:
	for real_btn in buttons:
		if !_first_real_btn:
			_first_real_btn = real_btn
			_first_real_btn.set_pressed_no_signal(true)
		real_btn.toggle_mode = true
		real_btn.button_group = btn_group
		(real_btn as Button).toggled.connect(flush_view_visibility)
	flush_view_visibility(true)

var _cached_active_index: int = -99
func flush_view_visibility(is_pressed: bool) -> void:
	#if !is_pressed:
		#return
	print('flush_view_visibility() --------------------------')
	var btn_group = buttons[0].button_group
	var real_btn: Button = btn_group.get_pressed_button()
	print('btn_group.get_buttons().size()')
	print(btn_group.get_buttons().size())
	print('btn_group')
	print(btn_group)
	print('real_btn')
	print(real_btn)
	var active_index: int = buttons.find(real_btn)
	print('active_index = %d' % active_index)
	print('_cached_active_index = %d' % _cached_active_index)
	var is_changed: bool = _cached_active_index != active_index
	print('is_changed = ')
	print(is_changed)
	_cached_active_index = active_index
	if true && contents_enabled:
		for view in contents:
			(view as Control).visible = contents.find(view) == _cached_active_index


## TODO: Listen to game controller L1/R1
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(_JoypadControlGroup_map[hierarchy_layer][0]):
		print("try_prev_tab() ---")
		try_prev_tab()
		return
	if Input.is_action_just_pressed(_JoypadControlGroup_map[hierarchy_layer][1]):
		print("try_next_tab() ---")
		try_next_tab()
		return

func try_prev_tab() -> void:
	if _cached_active_index > 0 + disabled_at_start:
		print("_activate_another(-1)")
		_activate_another(-1)
	else:
		print("Cannot move prev!")

func try_next_tab() -> void:
	if _cached_active_index < buttons.size() - 1 - disabled_at_end:
		print("_activate_another(+1)")
		_activate_another(+1)
	else:
		print("Cannot move next!")

func _activate_another(shift: int):
	if !is_joypad_active || !buttons[disabled_at_start].is_visible_in_tree():
		print("if !is_joypad_active || !buttons[0].is_visible_in_tree():")
		return
	print('_activate_another(%d)' % shift)
	print(btn_group.get_pressed_button())
	var real_btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(real_btn)
	var new_btn: Button = buttons[active_index+shift]
	if !new_btn.visible:
		### If the new button is hidden, abort current task!
		print("### If the new button is hidden, abort current task!")
		return
	(buttons[active_index+shift] as Button).button_pressed = true
	(buttons[active_index+shift] as Button).pressed.emit()
	(buttons[active_index] as Button).button_pressed = false
	print("flush_view_visibility(true)")
	flush_view_visibility(true)
