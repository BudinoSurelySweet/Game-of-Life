extends Camera2D

class_name PanningCamera2D

const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 2.5
const ZOOM_RATE: float = 8.0
const ZOOM_INCREMENT: float = 0.5

var _target_zoom: float = 1.0
var disable_camera_movement: bool = false


func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))


func _unhandled_input(event: InputEvent) -> void:
	if not disable_camera_movement:
		if event is InputEventMouseButton:
			if event.is_pressed():
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					zoom_out()
				if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					zoom_in()
				if event.double_click:
					focus_position(get_global_mouse_position())
		if event is InputEventMouseMotion:
			if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
				if zoom > Vector2(1.5, 1.5):
					position -= event.relative * zoom / 3
				elif zoom > Vector2(0.5, 0.5):
					position -= event.relative * zoom * 10
				else:
					position -= event.relative * zoom * 100


func zoom_in() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)


func zoom_out() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)


func focus_position(target_position: Vector2) -> void:
	var _tween = get_tree().create_tween()
	_tween.tween_property(self, "position", target_position, 0.2)
