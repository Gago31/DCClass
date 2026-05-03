@abstract
class_name VisualEntityWidget
extends EntityWidget


const SELECTION_AREA = preload("uid://n1s02t8kd0hl")


var bounds: Rect2
var selection_area: SelectionArea
var _prev_pos: Vector2
var _prev_scale: Vector2
#var _prev_transform: Transform2D

func move(translation: Vector2) -> void:
	position += translation
	get_entity().transform = get_entity().transform.translated(translation)
	_prev_pos = global_position

func move_to(point: Vector2) -> void:
	global_position = point
	get_entity().transform.origin = point
	_prev_pos = global_position

func scale_uniform(factor: float) -> void:
	global_scale *= factor
	get_entity().transform = get_entity().transform.scaled(Vector2(factor, factor))
	_prev_scale = global_scale

func temp_drag(displacement: Vector2) -> void:
	global_position = _prev_pos + displacement

func temp_scale(factor: float) -> void:
	global_scale = _prev_scale * factor
	#global_rotation = _prev_pos + displacement

func restore_transform() -> void:
	global_position = _prev_pos
	global_scale = _prev_scale
#@abstract func is_in_area(area: Rect2) -> void;

@abstract func _compute_bounds() -> Rect2;

func get_rect_bound() -> Rect2:
	if not bounds:
		bounds = _compute_bounds()
	return bounds

#@abstract func _on_select() -> void;
#@abstract func _on_deselect() -> void;

func select() -> void:
	modulate = Color.AQUA
	#_on_select()

func deselect() -> void:
	modulate = Color.WHITE
	#_on_deselect()

func get_entity() -> VisualEntity:
	return entity as VisualEntity

func setup() -> void:
	transform = get_entity().transform
	_prev_pos = global_position
	_prev_scale = global_scale
	#_prev_transform = get_entity().transform
	selection_area = SELECTION_AREA.instantiate() as SelectionArea
	add_child(selection_area)
	selection_area.setup_for_widget(self)
	#selection_area.clicked.connect(_on_clicked)
	hide()
