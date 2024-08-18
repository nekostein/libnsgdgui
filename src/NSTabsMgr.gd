class_name NSTabsMgr
extends Node

@export var buttons: Array[Button] = []
@export var contents: Array[Control] = []

@onready var btn_group: ButtonGroup = ButtonGroup.new()

func _ready() -> void:
	for btn: Button in buttons:
		btn.toggle_mode = true
		btn.button_group = btn_group
		btn.button_up.connect(_on_tab_button_up)

func _on_tab_button_up() -> void:
	var btn: Button = btn_group.get_pressed_button()
	var active_index: int = buttons.find(btn)
	for view in contents:
		view.visible = contents.find(view) == active_index
