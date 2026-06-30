extends Node2D

class_name Board

@onready var square : Resource = preload("res://figures/square/square.tscn")
@onready var board_box : Line2D = $BoardBox
@onready var lines : Node2D = $Lines

@export var columns_count : int = 10
@export var rows_count : int = 20 
@export var cell_size : int = 20

var cur_block : Figure = null

var fig_spawn_grid_pos : Vector2 = Vector2(0, 0)
var grid_shift : Vector2

func _ready() -> void:
	# setup line2D box as a board limit (for now)
	#for i in len(board_box.points):
		#var point_rel_pos : Vector2 = Vector2(sign(board_box.points[i].x), sign(board_box.points[i].y))
		#board_box.set_point_position(i, point_rel_pos * Vector2(columns_count + 1, rows_count + 1) * cell_size)
		#print(board_box.points[i])
	
	# update position of the board, to make lft bottom corner at (0, 0)
	#board_box.position = Vector2(0, -1 * (rows_count + 1) * cell_size)
	
	# set spawn point at the top of the screen in grid position
	fig_spawn_grid_pos = Vector2(round(columns_count / 2), -(rows_count + 2))
	
	# set width, of the line
	board_box.width = cell_size
	
	# set grid shift
	grid_shift = Vector2(board_box.width / 2, -board_box.width / 2)
	
	## testing, that child will be placed at correct possition
	var new_child = square.instantiate()
	cur_block = new_child
	add_child(cur_block)
	
	for i in range(rows_count):
		var new_line : Node2D = Node2D.new()
		new_line.name = "Line_%s" % i
		lines.add_child(new_line)
	
	print(lines.get_children())

#func _process(delta: float) -> void:
	#print(position)

func _grid_to_pos(grid_pos : Vector2) -> Vector2:
	return grid_shift + cell_size * grid_pos

func _pos_to_grid(pos : Vector2) -> Vector2:
	return (pos - grid_shift) / cell_size
	#return grid_shift + cell_size * grid_pos

func _on_child_entered_tree(node: Node) -> void:
	# if Figure was added, place it at specific place
	if node is Figure:
		fig_spawn_grid_pos.x = fig_spawn_grid_pos.x - int(node.width / 2)
		node.position = self._grid_to_pos(fig_spawn_grid_pos)


func _on_down_timer_timeout() -> void:
	# transform position to grid format
	var grid_pos : Vector2 = self._pos_to_grid(cur_block.position)
	
	# move figure down by 1
	if grid_pos.y < 0:
		grid_pos.y += 1
	
	# update possition of the figure in the world
	cur_block.position = self._grid_to_pos(grid_pos)
