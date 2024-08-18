class_name NSTabsMgr
extends Node

@export var buttons: Array[Control] = []
@export var contents: Array[Control] = []
@export var is_active: bool = true # TODO: If true, listen to game controller switching (L1/R1, etc)

var btn_group: ButtonGroup = ButtonGroup.new()

var _first_real_btn: Button = null

func _ready() -> void:
	for real_btn in buttons:
		if !_first_real_btn:
			_first_real_btn = real_btn
			_first_real_btn.set_pressed_no_signal(true)
		real_btn.toggle_mode = true
		real_btn.button_group = btn_group
		real_btn.button_up.connect(flush_view_visibility)
	flush_view_visibility()

var _cached_active_index: int = -99
func flush_view_visibility() -> void:
	var real_btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(real_btn)
	var is_changed: bool = _cached_active_index != active_index
	_cached_active_index = active_index
	if is_changed:
		for view in contents:
			view.visible = contents.find(view) == active_index


### TODO: Listen to game controller L1/R1
#func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("gc_l1"):
		#try_prev_tab()
		#return
	#if Input.is_action_just_pressed("gc_r1"):
		#try_next_tab()
		#return
#
#func try_prev_tab() -> void:
	#pass
#
#func try_next_tab() -> void:
	#pass
