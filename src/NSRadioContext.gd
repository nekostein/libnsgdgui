class_name NSRadioContext
extends Node

@export var containers: Array[Control] = []

@onready var btn_group: ButtonGroup = ButtonGroup.new()

func _ready() -> void:
	for container: Control in containers:
		for btn in container.get_children():
			if btn is Button:
				btn.button_group = btn_group
