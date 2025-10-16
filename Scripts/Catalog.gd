extends Node

const FURNITURE_PATH = "res://Furnitures/"
const THUMBNAIL_PATH = "res://Thumbnails/"

@onready var grid_container := get_parent().get_node("GridContainer")

func _ready():
	var furniture_files = get_furniture_paths(FURNITURE_PATH)
	for path in furniture_files:
		var thumbnail_file = THUMBNAIL_PATH + path.get_file().get_basename() + ".png"
		var button := TextureButton.new()
		button.ignore_texture_size = true
		button.stretch_mode = TextureButton.STRETCH_SCALE
		button.custom_minimum_size = Vector2(128, 128)  # Adjust as needed


		if FileAccess.file_exists(thumbnail_file):
			var image := Image.new()
			var err := image.load(thumbnail_file)
			if err == OK:
				var texture := ImageTexture.create_from_image(image)
				button.texture_normal = texture
			else:
				print("Failed to load thumbnail for: ", path)
		else:
			print("Thumbnail missing for: ", path)

		button.connect("pressed", Callable(self, "_on_furniture_selected").bind(path))
		grid_container.add_child(button)

func get_furniture_paths(folder_path: String) -> Array:
	var dir = DirAccess.open(folder_path)
	var paths = []
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tscn") or file.ends_with(".glb"):
				paths.append(folder_path + file)
	return paths

func spawn_furniture(path: String, parent: Node):
	var model = load(path)
	if model:
		var instance = model.instantiate()
		parent.add_child(instance)
		instance.position = Vector3(0, 0, 0)

func _on_furniture_selected(path: String):
	var parent_node := get_tree().get_root().get_node("main")  # Adjust path as needed
	spawn_furniture(path, parent_node)
