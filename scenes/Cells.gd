extends TileMap

const DEAD_CELL_ID : int = 0
const LIVING_CELL_ID : int = 1

var map : Vector2i = Vector2i(32, 18)
var _cells_to_check : Dictionary
var _next_generation_cells : Dictionary

var _edit_mode : bool = true
var _mouse_left_click_pressed : bool = false
var _mouse_right_click_pressed : bool = false

var _mouse_pos : Vector2i

@onready var next_generation_timer : Timer = $NextGeneration


func _ready():
	next_generation_timer.connect("timeout", _next_generation)
	
	for x in map.x:
		for y in map.y:
			set_cell(0, Vector2i(x, y), DEAD_CELL_ID, Vector2i(0, 0))


func _input(event):
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
	_mouse_pos = Vector2i(get_global_mouse_position())
	
	set_cell(0, _mouse_pos, LIVING_CELL_ID, Vector2i(0, 0))


func _death() -> void:
	# get the mouse global position without the decimal number
	_mouse_pos = Vector2i(get_global_mouse_position())
	
	set_cell(0, _mouse_pos, DEAD_CELL_ID, Vector2i(0, 0))


func _next_generation() -> void:
	for x in map.x:
		for y in map.y:
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
			
			# rules
			if curr_cell_status:
				if adjacent_living_cells < 2 or adjacent_living_cells > 3:
					# la cella muore per effetto di isolamento (<2) o per effetto di sovrappopolazione (>3)
					_next_generation_cells[str(Vector2i(x, y))] = {
						"Position" : Vector2i(x, y), 
						"Life" : DEAD_CELL_ID
					}
				elif adjacent_living_cells == 2 or adjacent_living_cells == 3:
					# la cella vive
					_next_generation_cells[str(Vector2i(x, y))] = {
						"Position" : Vector2i(x, y), 
						"Life" : LIVING_CELL_ID
					}
			else:
				if adjacent_living_cells == 3:
					# la cella nasce per effetto di riproduzione
					_next_generation_cells[str(Vector2i(x, y))] = {
						"Position" : Vector2i(x, y), 
						"Life" : LIVING_CELL_ID
					}
	
	for cell in _next_generation_cells:
		set_cell(0, _next_generation_cells[cell]["Position"], _next_generation_cells[cell]["Life"], Vector2i(0, 0))
	
	_next_generation_cells.clear()
	
	next_generation_timer.start()
