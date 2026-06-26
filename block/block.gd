extends Node2D

class_name Block

@onready var number_label : Label = $Label

@export var number : int = 0

func _ready() -> void:
	# write down index of the block for visual understanding
	number_label.text = str(number)
