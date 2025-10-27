extends Node3D
const RAY_LENGTH = 1000.0
const ROT_ANGLE = PI*0.05

var isDragging = false
var selectedFurniture: Node3D = null

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if !event.pressed:
				if not isDragging:
					select_furniture(event.position)
					if selectedFurniture:
						selectedFurniture.set_collision_layer_value(1, false)
						var furnitureMesh := selectedFurniture.get_node("MeshInstance3D") as MeshInstance3D
						var material := furnitureMesh.get_active_material(0)
						if(material is ShaderMaterial):
							material.set_shader_parameter("opacity", 0.45)
				else:
 					#Check if released outside of ground
					if not is_mouse_over_ground(event.position):
						if selectedFurniture:
							selectedFurniture.queue_free()
							selectedFurniture = null
					else:
						place_furniture()
				# On mouse release, toggle dragging state
				isDragging = selectedFurniture != null and not isDragging
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP && isDragging && selectedFurniture != null:
			selectedFurniture.rotate_y(ROT_ANGLE);
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN && isDragging && selectedFurniture != null:
			selectedFurniture.rotate_y(-ROT_ANGLE);


func _physics_process(_delta):
	if isDragging && selectedFurniture != null:
			var mouse_pos = get_viewport().get_mouse_position()
			var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
			var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * RAY_LENGTH

			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.new()
			query.from = from
			query.to = to
			query.collide_with_areas = true
			query.collide_with_bodies = true

			var result = space_state.intersect_ray(query)
			if result:
				var tempPosition = result.position
				tempPosition.y += 1.0
				# print("Position : ", result.collider.name)
				# print("Position : ", tempPosition)
				selectedFurniture.position = tempPosition


func select_furniture(mouse_pos: Vector2):
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * RAY_LENGTH

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	if result and result.collider.is_in_group("furniture"):
		selectedFurniture = result.collider
		print("Selected:", selectedFurniture.name)

func place_furniture():
	if selectedFurniture:
		selectedFurniture.position.y -= 1.0
		selectedFurniture.set_collision_layer_value(1, true)
		var furnitureMesh := selectedFurniture.get_node("MeshInstance3D") as MeshInstance3D
		var material := furnitureMesh.get_active_material(0)
		if(material is ShaderMaterial):
			material.set_shader_parameter("opacity", 1.0)
		selectedFurniture = null
		isDragging = false
		print("Furniture placed.")


func is_mouse_over_ground(mouse_pos: Vector2) -> bool:
	var from = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var to = from + get_viewport().get_camera_3d().project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	if result:
		return true
	return false
