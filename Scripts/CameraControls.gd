extends Node3D

@export var edge_threshold: int = 100  # Pixels from edge to start moving
@export var move_speed: float = 30.0   # Units per second
@export var move_smoothing: float = 8.0 # Higher = faster response
@export var rotation_speed = 0.01

var rotating = false
var translation_speed = Vector3.ZERO

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position();
	var screen_size = get_viewport().get_visible_rect().size;
	var window_size = DisplayServer.window_get_size();
	
	# Check if mouse is inside the window
	var direction = Vector3.ZERO
	if !rotating && mouse_pos.x >= 0 and mouse_pos.y >= 0 and mouse_pos.x <= window_size.x and mouse_pos.y <= window_size.y:
		# Move along X axis
		if mouse_pos.x <= edge_threshold:
			direction.x -= (edge_threshold-mouse_pos.x)/edge_threshold
		elif mouse_pos.x >= screen_size.x - edge_threshold:
			direction.x += (mouse_pos.x - (screen_size.x - edge_threshold))/edge_threshold

		# Move along Z axis (forward/backward)
		if mouse_pos.y <= edge_threshold:
			direction.z -= (edge_threshold-mouse_pos.y)/edge_threshold
		elif mouse_pos.y >= screen_size.y - edge_threshold:
			direction.z += (mouse_pos.y - (screen_size.y - edge_threshold))/edge_threshold

	if direction != Vector3.ZERO || translation_speed != Vector3.ZERO:

		var x_rotation_radians = deg_to_rad(rotation_degrees.x)
		var x_basis = Basis(Vector3(1, 0, 0), -x_rotation_radians)
		var rotated_direction = x_basis * direction
		# Smoothly interpolate velocity toward target direction
		translation_speed = translation_speed.lerp(rotated_direction * move_speed, move_smoothing * delta)
	
	if translation_speed != Vector3.ZERO:
		# Move the camera using rotated direction
		translate(translation_speed * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			rotating = event.pressed

	elif event is InputEventMouseMotion and rotating:
		var x_rot = -event.relative.y * rotation_speed
		# Clamp vertical rotation to avoid flipping
		var camera_rot = clamp(rotation_degrees.x+rad_to_deg(x_rot), -80, 0);
		rotation_degrees.x = camera_rot;
		rotation_degrees.z = 0.0;
		
		rotate_y(-event.relative.x * rotation_speed)
