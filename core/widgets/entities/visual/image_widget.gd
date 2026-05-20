class_name ImageWidget
extends VisualEntityWidget

## [VisualEntityWidget] that displays an image in the whiteboard.


@onready var image: TextureRect = %Image


func setup() -> void:
	super.setup()
	if ClassResourceLoader.image_exists(get_entity().image_path):
		_on_image_converted(false)
	else:
		get_entity().conversion_finished.connect(_on_image_converted)
	hide()

func _calculate_duration() -> float:
	return 0.0

func get_entity() -> ImageEntity:
	return entity as ImageEntity

func _on_started_playing() -> void:
	show()
	finish_playing()

func _on_reset():
	hide()

func _on_skip() -> void:
	show()

func clear():
	reset()

func _compute_bounds() -> Rect2:
	if image:
		return Rect2(Vector2.ZERO, image.size)
	return Rect2()

func _on_image_converted(_err: bool) -> void:
	image.texture = ClassResourceLoader.load_image(get_entity().image_path)
