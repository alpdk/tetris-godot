extends Node2D

class_name Block

@export var number : int = 0

@onready var number_label : Label = $Label

func _ready() -> void:
	number_label.text = str(number)
