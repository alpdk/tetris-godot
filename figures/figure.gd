@abstract
class_name Figure
extends Node2D

@export var width : int = 0
@export var height : int = 0

var block_size : int = 20

@onready var blocks : Node2D = $Blocks

func _ready() -> void:
	set_width_and_height()

func rotate_fig() -> void:
	var vertical_shift : int = -max(height, width)
	var new_pos_on_grid : Array = []
	
	print(width, ' ', height)
	# center of our figure in grid format
	var center_of_fig : Vector2 = Vector2(float(max(width, height)) / 2, -float(max(width, height)) / 2)
	print(center_of_fig)
	
	# update each block position
	for block in blocks.get_children():
		# position of the block center in grid format
		var block_center_in_greed : Vector2 = block.position / block_size + Vector2(0.5, -0.5)
		
		# vector from fig's center to block's center
		var fig_to_block_cent : Vector2 = center_of_fig - block_center_in_greed
		
		# rotated vector on 90 degree
		var rotated_vec : Vector2 = Vector2(fig_to_block_cent.y, -fig_to_block_cent.x)
		
		# new position of the block at grid
		var new_grid_pos : Vector2 = center_of_fig + rotated_vec - Vector2(0.5, -0.5)
		
		vertical_shift = max(vertical_shift, new_grid_pos.y)
		new_pos_on_grid.append(new_grid_pos)
	
	#print(new_pos_on_grid)
	
	for i in range(len(blocks.get_children())):
		blocks.get_child(i).position = Vector2(new_pos_on_grid[i].x, new_pos_on_grid[i].y - vertical_shift) * block_size
		#print(blocks.get_child(i).position)
	
	# change to global method swap
	var temp = width
	width = height
	height = temp

func get_width() -> int:
	return width

func get_height() -> int:
	return height

func set_width_and_height() -> void:
	for child in blocks.get_children():
		#print(child.position)
		width = max(width, int(child.position.x / block_size)  + 1)
		height = max(height, int(- child.position.y / block_size) + 1)
