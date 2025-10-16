extends Node3D

const FURNITURE_PATH = "res://Furniture/"
const THUMBNAIL_PATH = "res://Thumbnails/"
const VIEWPORT_SIZE = Vector2i(256, 256)

@onready var viewport := $ThumbnailViewport
@onready var camera := $ThumbnailViewport/Camera3D

func _ready():
	var furniture_files = get_furniture_paths(FURNITURE_PATH)
	for path in furniture_files:
		var thumbnail_file = THUMBNAIL_PATH + path.get_file().get_basename() + ".png"
		if not FileAccess.file_exists(thumbnail_file):
			generate_thumbnail(path, thumbnail_file)

func get_furniture_paths(folder_path: String) -> Array:
	var dir = DirAccess.open(folder_path)
	var paths = []
	if dir:
		for file in dir.get_files():
			if file.ends_with(".tscn") or file.ends_with(".glb"):
				paths.append(folder_path + file)
	return paths

func generate_thumbnail(model_path: String, save_path: String):
	var model = load(model_path)
	if model:
		var instance = model.instantiate()
		viewport.size = VIEWPORT_SIZE
		viewport.add_child(instance)
		instance.global_transform.origin = Vector3(0, 0, 0)
		camera.look_at(Vector3(0, 0, 0), Vector3.UP)

		await get_tree().process_frame  # Wait for rendering
		var image = viewport.get_texture().get_image()
		image.save_png(save_path)

		instance.queue_free()
