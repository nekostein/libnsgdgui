class_name NSTabsMgr
extends Node

@export var buttons: Array[Control] = []
@export var contents: Array[Control] = []
@export var contents_enabled: bool = true # If false, ignore contents
@export var is_joypad_active: bool = true # If true, allows game controller
@export var hierarchy_layer: JoypadControlGroup = JoypadControlGroup.L1_R1

@export var disabled_at_start: int = 0 # Hide initial N tabs
@export var disabled_at_end: int = 0 # Hide last N tabs
@export var is_index_remembered: bool = true

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
@onready var _localstorage_meta_key = "NSTabsMgr_" + str(self.get_path().hash()) + "_cached_active_index"


func _ready() -> void:
	var _has_got_cached: bool = is_index_remembered && _dbread_tab_index_persistant()
	for real_btn in buttons:
		if !_first_real_btn:
			_first_real_btn = real_btn
			_first_real_btn.set_pressed_no_signal(true)
		real_btn.toggle_mode = true
		real_btn.button_group = btn_group
		(real_btn as Button).toggled.connect(flush_view_visibility)
	if _has_got_cached:
		### '_retrived_index_from_persistant' has been modified; should read from it!
		_activate_another(_retrived_index_from_persistant, true)
	else:
		flush_view_visibility(true)
	_flush_cached_active_index()


func _flush_cached_active_index():
	_cached_active_index = buttons.find(btn_group.get_pressed_button())


var _cached_active_index: int = -99
func flush_view_visibility(is_pressed: bool) -> void:
	var btn_group = buttons[0].button_group
	var real_btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(real_btn)
	var is_changed: bool = _cached_active_index != active_index
	_cached_active_index = active_index
	if true && contents_enabled:
		for view in contents:
			(view as Control).visible = contents.find(view) == _cached_active_index
	_dbwrite_tab_index_persistant()


var _retrived_index_from_persistant: int = -1
func _dbread_tab_index_persistant() -> bool:
	if !get_tree().root.has_meta(_localstorage_meta_key): # No data stored; abort reading
		return false
	var index: int = get_tree().root.get_meta(_localstorage_meta_key)
	if index >= 0:
		_retrived_index_from_persistant = index
		return true
	return false

func _dbwrite_tab_index_persistant():
	get_tree().root.set_meta(_localstorage_meta_key, _cached_active_index)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(_JoypadControlGroup_map[hierarchy_layer][0]):
		try_prev_tab()
		return
	if Input.is_action_just_pressed(_JoypadControlGroup_map[hierarchy_layer][1]):
		try_next_tab()
		return

func try_prev_tab() -> void:
	if _cached_active_index > 0 + disabled_at_start:
		_activate_another(-1, false)
	#else:
		#print("Cannot move prev!")

func try_next_tab() -> void:
	if _cached_active_index < buttons.size() - 1 - disabled_at_end:
		_activate_another(+1, false)
	#else:
		#print("Cannot move next!")

func _activate_another(shift: int, is_programatically_changing: bool):
	### Skip if joypad is not set to be active or is invisible; but allow programmatical changes
	if !buttons[disabled_at_start].get_parent().is_visible_in_tree() && !is_programatically_changing:
		return
	if !is_joypad_active && !is_programatically_changing:
		return
	#print('_activate_another(%d)' % shift)
	#print(btn_group.get_pressed_button())
	var real_btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(real_btn)
	var new_btn: Button = buttons[active_index+shift]
	if !new_btn.visible:
		### If the new button is hidden, abort current task!
		#print("### If the new button is hidden, abort current task!")
		return
	new_btn.button_pressed = true
	new_btn.pressed.emit()
	#flush_view_visibility(true)
