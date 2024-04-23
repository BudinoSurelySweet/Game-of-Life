extends TileMap

var map : int = 32
var _next_generation_cells : Dictionary
var _edit_mode : bool = true
var _mouse_left_click_pressed : bool = false
var _mouse_right_click_pressed : bool = false
var _prev_mouse_pos : Vector2i
var _mouse_pos : Vector2i : 
	set(new_value):
		_mouse_pos = new_value
		
		if _prev_mouse_pos != _mouse_pos:
			_prev_mouse_pos = _mouse_pos

@onready var next_generation_timer : Timer = $NextGeneration


func _ready():
	next_generation_timer.connect("timeout", _next_generation)
	
	for x in map:
		for y in map:
			set_cell(0, Vector2i(x, y), false, Vector2i(0, 0))


func _input(event):
	if event.is_action_pressed("start_life"):
		_edit_mode = not _edit_mode
	
	if _edit_mode:
		next_generation_timer.stop()
		
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_LEFT:
					_mouse_left_click_pressed = true
					
					_born()
				
				if event.button_index == MOUSE_BUTTON_RIGHT:
					_mouse_right_click_pressed = true
					
					_death()
			
			if event.is_released():
				if event.button_index == MOUSE_BUTTON_LEFT:
					_mouse_left_click_pressed = false
				
				if event.button_index == MOUSE_BUTTON_RIGHT:
					_mouse_right_click_pressed = false
		
		if event is InputEventMouseMotion:
			if _mouse_left_click_pressed:
				_born()
			
			if _mouse_right_click_pressed:
				_death()
	else:
		next_generation_timer.start()


func _born() -> void:
	# get the mouse global position without the decimal number
	_mouse_pos = Vector2i(get_global_mouse_position())
	
	set_cell(0, _mouse_pos, true, Vector2i(0, 0))


func _death() -> void:
	# get the mouse global position without the decimal number
	_mouse_pos = Vector2i(get_global_mouse_position())
	
	set_cell(0, _mouse_pos, false, Vector2i(0, 0))


func _next_generation() -> void:
	for x in map:
		for y in map:
			var curr_cell_status = get_cell_source_id(0, Vector2i(x, y))
			var adjacent_cells_pos : Array = [
				Vector2i(x-1, y-1),
				Vector2i(x, y-1),
				Vector2i(x+1, y-1),
				Vector2i(x-1, y),
				Vector2i(x+1, y),
				Vector2i(x-1, y+1),
				Vector2i(x, y+1),
				Vector2i(x+1, y+1),
			]
			
			var adjacent_living_cells : int = 0
			
			for cell_pos in adjacent_cells_pos:
				if get_cell_source_id(0, cell_pos) == 1:
					adjacent_living_cells += 1
			
			if curr_cell_status:
				if adjacent_living_cells < 2 or adjacent_living_cells > 3:
					# la cella muore
					_next_generation_cells[str(Vector2i(x, y))] = {
						"Position" : Vector2i(x, y), 
						"Life" : false
					}
				elif adjacent_living_cells == 2 or adjacent_living_cells == 3:
					# la cella vive
					_next_generation_cells[str(Vector2i(x, y))] = {
						"Position" : Vector2i(x, y), 
						"Life" : true
					}
			else:
				if adjacent_living_cells == 3:
					# la cella nasce
					_next_generation_cells[str(Vector2i(x, y))] = {
						"Position" : Vector2i(x, y), 
						"Life" : true
					}
	
	for cell in _next_generation_cells:
		set_cell(0, _next_generation_cells[cell]["Position"], _next_generation_cells[cell]["Life"], Vector2i(0, 0))
	
	_next_generation_cells.clear()
	
	next_generation_timer.start()
