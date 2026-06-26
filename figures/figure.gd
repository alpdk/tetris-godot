@abstract
class_name Figure
extends Node2D

var width : int = 0
var height : int = 0

var block_size : int = 20

@onready var blocks : Node2D = $Blocks

@abstract func rotate_fig() -> void

func get_width() -> int:
	return width

func get_height() -> int:
	return height

func set_width_and_height() -> void:
	for child in blocks.get_children():
		#print(child.position)
		width = max(width, int(child.position.x / block_size)  + 1)
		height = max(height, int(- child.position.y / block_size) + 1)
