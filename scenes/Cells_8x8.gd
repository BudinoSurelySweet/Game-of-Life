extends TileMap

const DEAD_CELL_ID : int = 0
const LIVING_CELL_ID : int = 1

var cell_resolution : int = 8

var _next_generation_cells : Dictionary
var _curr_living_cells : Array[Vector2i]
var _next_generation_living_cells : Array[Vector2i]

var _edit_mode : bool = true
var _mouse_left_click_pressed : bool = false
var _mouse_right_click_pressed : bool = false

var _mouse_pos : Vector2i

@onready var next_generation_timer : Timer = $NextGeneration


func _ready():
	next_generation_timer.connect("timeout", _TEMP_next_generation)


func _input(event):
	if event.is_action_pressed("test"):
		print(_curr_living_cells)
	
	if event.is_action_pressed("start_life"):
		_edit_mode = not _edit_mode
	
	if _edit_mode:
		next_generation_timer.stop()
		
		# click mouse button
		if event is InputEventMouseButton:
			if event.is_pressed():
				# fai nacere la cella selezionata
				if event.button_index == MOUSE_BUTTON_LEFT:
					_mouse_left_click_pressed = true
					
					_born()
				
				# fai morire la cella selezionata
				if event.button_index == MOUSE_BUTTON_RIGHT:
					_mouse_right_click_pressed = true
					
					_death()
			
			if event.is_released():
				if event.button_index == MOUSE_BUTTON_LEFT:
					_mouse_left_click_pressed = false
				
				if event.button_index == MOUSE_BUTTON_RIGHT:
					_mouse_right_click_pressed = false
		
		# hold mouse button
		if event is InputEventMouseMotion:
			# fai nacere la cella selezionata
			if _mouse_left_click_pressed:
				_born()
			
			# fai morire la cella selezionata
			if _mouse_right_click_pressed:
				_death()
	else:
		if next_generation_timer.time_left == 0:
			next_generation_timer.start()


func _born() -> void:
	# get the mouse global position without the decimal number
	_mouse_pos = Vector2i(get_global_mouse_position()) / cell_resolution
	
	# search the current cell
	var cell = _curr_living_cells.find(_mouse_pos)
	
	# if the cell doesn't exist, add it
	if cell == -1:
		_curr_living_cells.append(_mouse_pos)
	
	# set the cell living
	set_cell(0, _mouse_pos, LIVING_CELL_ID, Vector2i(0, 0))


func _death() -> void:
	# get the mouse global position without the decimal number
	_mouse_pos = Vector2i(get_global_mouse_position()) / cell_resolution
	
	# search the current cell
	var cell = _curr_living_cells.find(_mouse_pos)
	
	# if the cell exist, remove it
	if cell != -1:
		_curr_living_cells.remove_at(cell)
	
	# set the cell dead
	set_cell(0, _mouse_pos, DEAD_CELL_ID, Vector2i(0, 0))


func _rules(x, y, curr_cell_status, adjacent_living_cells) -> void:
	var pos : Vector2i = Vector2i(x, y)
	
	if curr_cell_status:
		if adjacent_living_cells < 2 or adjacent_living_cells > 3:
			_next_generation_cells[str(pos)] = {
					"Position" : pos, 
					"Life" : DEAD_CELL_ID
			}
		elif adjacent_living_cells == 2:
			_next_generation_cells[str(pos)] = {
					"Position" : pos, 
					"Life" : LIVING_CELL_ID
			}
			
			if _next_generation_living_cells.find(pos) == -1:
				_next_generation_living_cells.append(pos)
			
	else:
		if adjacent_living_cells == 3:
			_next_generation_cells[str(pos)] = {
					"Position" : pos, 
					"Life" : LIVING_CELL_ID
			}
			
			if _next_generation_living_cells.find(pos) == -1:
				_next_generation_living_cells.append(pos)


# to adjust
func _TEMP_next_generation() -> void:
	for living_cell in _curr_living_cells:
		var lc_x : int = living_cell.x
		var lc_y : int = living_cell.y
		
		var chunk_3x3 : Array = [
			Vector2i(lc_x-1, lc_y-1),
			Vector2i(lc_x, lc_y-1),
			Vector2i(lc_x+1, lc_y-1),
			Vector2i(lc_x-1, lc_y),
			Vector2i(lc_x, lc_y),
			Vector2i(lc_x+1, lc_y),
			Vector2i(lc_x-1, lc_y+1),
			Vector2i(lc_x, lc_y+1),
			Vector2i(lc_x+1, lc_y+1),
		]
		
		for cell_to_check in chunk_3x3:
			var curr_cell_status = get_cell_source_id(0, cell_to_check)
			var ctc_x : int = cell_to_check.x
			var ctc_y : int = cell_to_check.y
			
			if curr_cell_status == 1 or curr_cell_status == 0:
				pass
			else:
				curr_cell_status = 0
			
			var adjacent_cells : Array = [
				Vector2i(ctc_x-1, ctc_y-1),
				Vector2i(ctc_x, ctc_y-1),
				Vector2i(ctc_x+1, ctc_y-1),
				Vector2i(ctc_x-1, ctc_y),
				Vector2i(ctc_x+1, ctc_y),
				Vector2i(ctc_x-1, ctc_y+1),
				Vector2i(ctc_x, ctc_y+1),
				Vector2i(ctc_x+1, ctc_y+1),
			]
			
			var adjacent_living_cells = 0
			
			for adjacent_cell in adjacent_cells:
				if get_cell_source_id(0, adjacent_cell) == 1:
					adjacent_living_cells += 1
			
			if _next_generation_cells.find_key(str(Vector2i(ctc_x, ctc_y))) == null:
				_rules(ctc_x, ctc_y, curr_cell_status, adjacent_living_cells)
	
	for cell in _next_generation_cells:
		set_cell(0, _next_generation_cells[cell]["Position"], _next_generation_cells[cell]["Life"], Vector2i(0, 0))
	
	_curr_living_cells.clear()
	
	_curr_living_cells.append_array(_next_generation_living_cells)
	
	_next_generation_living_cells.clear()
	_next_generation_cells.clear()
	
	next_generation_timer.start()
