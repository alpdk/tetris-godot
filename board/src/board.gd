extends Node2D

class_name Board

@onready var square : Resource = preload("res://figures/square/square.tscn")
@onready var board_box : Line2D = $BoardBox
@onready var lines : Node2D = $Lines
@onready var slide_delay : Timer = $SlideDelay

@export var columns_count : int = 10
@export var rows_count : int = 20 
@export var cell_size : int = 20

var cur_figure : Figure = null

var fig_spawn_grid_pos : Vector2i = Vector2i(0, 0)
var grid_shift : Vector2

var figure_list : Array[String] = []

func _load_figure_scene_paths() -> void:
	"""
	Method for loading path to the scene related to each figure in game
	"""
	# load diracces for dir with figures
	var path : String = "res://figures"
	var fig_shared_path : DirAccess = DirAccess.open(path)

	# check that dir exist
	if fig_shared_path == null:
		push_error("There is no such folder with figures: " + path)
		return
	
	fig_shared_path.list_dir_begin()
	
	var name : String = fig_shared_path.get_next()
	
	# go over all elements inside directory
	while name != "":
		if name != "." and name != "..":
			var full_path : String = "res://figures/" + name
			
			# load path fpr scens
			if fig_shared_path.current_is_dir():
				full_path += "/%s.tscn" % name
				figure_list.append(full_path)
			
		name = fig_shared_path.get_next()
	
	fig_shared_path.list_dir_end()

func _ready() -> void:
	# setup line2D box as a board limit (for now)
	#for i in len(board_box.points):
		#var point_rel_pos : Vector2 = Vector2(sign(board_box.points[i].x), sign(board_box.points[i].y))
		#board_box.set_point_position(i, point_rel_pos * Vector2(columns_count + 1, rows_count + 1) * cell_size)
		#print(board_box.points[i])
	
	# update position of the board, to make lft bottom corner at (0, 0)
	#board_box.position = Vector2(0, -1 * (rows_count + 1) * cell_size)
	
	# set spawn point at the top of the screen in grid position
	fig_spawn_grid_pos = Vector2i(columns_count / 2, -rows_count + 2)
	
	# set width, of the line
	board_box.width = cell_size
	
	# set grid shift
	grid_shift = Vector2(board_box.width / 2, -board_box.width / 2)
	
	## testing, that child will be placed at correct possition
	var new_child = square.instantiate()
	cur_figure = new_child
	add_child(cur_figure)
	
	# create nodes for each new line
	for i in range(rows_count):
		var new_line : Node2D = Node2D.new()
		new_line.name = "Line_%s" % int(-i)
		lines.add_child(new_line)
	
	# load names of figure scenese
	_load_figure_scene_paths()
	
#	print(lines.get_children())

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
		var shifted_spawn_pos : Vector2i = Vector2i(fig_spawn_grid_pos.x - int(node.width / 2), fig_spawn_grid_pos.y)
		node.position = self._grid_to_pos(shifted_spawn_pos)

func _collect_cur_figure_blocks_pos(fig_grid_pos : Vector2) -> Dictionary: 
	"""
	Method for collecting new figure blocks possition on the greed, which are require check, before move down
	
	Argument: 
		* fig_grid_pos (Vector2): grid position of the figure
	
	Returns:
		* Dictionary: dictionary of cells, below which we need to chek, that no obstacels
	"""
	var cur_dinemic_blocks : Array[Node] = cur_figure.get_blocks()
	var blocks_pos_dict : Dictionary = {}
	
	for block in cur_dinemic_blocks:
		# taking position of the block in grid format
		var block_pos : Vector2 = fig_grid_pos + block.position / cell_size
		
		# add or update block position in dictionary, that will require check
		if (block_pos.x not in blocks_pos_dict) or (block_pos.y > blocks_pos_dict[block_pos.x]):
			blocks_pos_dict[block_pos.x] = block_pos.y
	
	return blocks_pos_dict 

func _check_below_for_obstacles(blocks_cur_pos : Dictionary) -> bool:
	"""
	Check, if there is any obstacel, below the figure
	
	Argument: 
		* blocks_cur_pos (Dictionary): dictionary of cells, below which we need to check, that no obstacels
	
	Returns:
		* bool: true, if there is any obstacel (any other block, or the base, of the board), 
				below the figure, otherwise false
	"""
	# for each block in the figure, check if there is any block below
	for block_column in blocks_cur_pos.keys():
		if blocks_cur_pos[block_column] == 0:
			print("GROUND FLOOR!!! STOP MOVING!!!")
			return true
		
		var position_below : Vector2i = Vector2i(block_column, blocks_cur_pos[block_column] + 1)
		var check_pos : NodePath = NodePath("./Lines/Line_%s/Block_%s" % [position_below.y, position_below.x])
		
		if has_node(check_pos):
			print("AN OBSTACLE!!! STOP MOVING!!!")
			return true
	
	print("No obstacle")
	return false

func _load_new_fig():
	"""
	Method for loading new figure, when is was deleted
	"""
	var path_to_load : String = figure_list[randi_range(0, len(figure_list) - 1)]
	var new_figure_scene: PackedScene = load(path_to_load)
	
	if new_figure_scene == null:
		push_error("Failed to load scene: " + path_to_load)
		return
	
	cur_figure = new_figure_scene.instantiate()
	add_child(cur_figure)

func _move_fig_blocks_to_lines(fig_grid_pos : Vector2):
	"""
	Move blocks of the current figure to the lines
	
	Argument: 
	* fig_grid_pos (Vector2): grid position of the figure
	"""
	var blocks : Array[Node] = cur_figure.get_blocks()
	
	for block in blocks:
		var block_pos : Vector2i = fig_grid_pos + block.position / cell_size
		
		# THERE IS A BUG!!! TRY TO FIX IT!!!
		var target_line : Node = get_node("./Lines/Line_%s" % block_pos.y)
		block.name = "Block_%s" % block_pos.x
		
		block.reparent(target_line)
#		var node_path : NodePath = NodePath("./Lines/Line_%s/Block_%s" % [block_pos.y, block_pos.x])
	cur_figure.queue_free()
	
	_load_new_fig()

func _on_down_timer_timeout() -> void:
	if cur_figure == null:
		return
	
	# transform position to grid format
	var fig_grid_pos : Vector2 = self._pos_to_grid(cur_figure.position)
	
	# dictionary of cells, below which we need to chek, that no obstacels
	var blocks_cur_pos : Dictionary = self._collect_cur_figure_blocks_pos(fig_grid_pos)
	
	if self._check_below_for_obstacles(blocks_cur_pos):
#		cur_figure.queue_free()
#		There should be code, that will move blocks, into lines
		self._move_fig_blocks_to_lines(fig_grid_pos)
	else:
		# move figure down by 1
		if fig_grid_pos.y < 0:
			fig_grid_pos.y += 1
		
		# update possition of the figure in the world
		cur_figure.position = self._grid_to_pos(fig_grid_pos)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("slide_left") and cur_figure != null and slide_delay.is_stopped():
		var grid_pos : Vector2 = self._pos_to_grid(cur_figure.position)
		cur_figure.position = self._grid_to_pos(Vector2(max(grid_pos.x - 1, 0), grid_pos.y))
		slide_delay.start()
	elif Input.is_action_pressed("slide_right") and cur_figure != null and slide_delay.is_stopped():
		var grid_pos : Vector2 = self._pos_to_grid(cur_figure.position)
		cur_figure.position = self._grid_to_pos(Vector2(min(grid_pos.x + 1, columns_count - cur_figure.get_width()), grid_pos.y))
		slide_delay.start()

#func _input(event: InputEvent) -> void:
	#if event.is_action("slide_left") and cur_figure != null:
		#var grid_pos : Vector2 = self._pos_to_grid(cur_figure.position)
		#cur_figure.position = self._grid_to_pos(Vector2(max(grid_pos.x - 1, 0), grid_pos.y))
	#elif event.is_action("slide_right") and cur_figure != null:
		#var grid_pos : Vector2 = self._pos_to_grid(cur_figure.position)
		#cur_figure.position = self._grid_to_pos(Vector2(min(grid_pos.x + 1, columns_count - cur_figure.get_width()), grid_pos.y))
