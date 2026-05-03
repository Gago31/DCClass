# 1. class name: fill the class name
class_name PenColorEntity
extends Entity

# 2. docs: use docstring (##) to generate docs for this file
## An [Entity] that represents a pen color change operation

# 3. signals: define signals here

# 4. enums: define enums here

# 5. constants: define constants here

# 6. export variables: define all export variables in groups here
@export var color: Color

# 7. public variables: define all public variables here

# 8. private variables: define all private variables here, use _ as preffix

# 9. onready variables: define all onready variables here

# 10. init virtual methods: define _init, _enter_tree and _ready mothods here

func _init() -> void:
	entity_id = "PenColor"

func get_widget() -> PackedScene:
	return preload("uid://cpfenn5p8def4")

# Deletes this entity.:

# 11. virtual methods: define other virtual methos here

# 12. public methods: define all public methods here
func get_class_name() -> String:
	return "PenColorEntity"
	
func get_editor_name() -> String:
	return "Color: " + str(color)

# Serialize to a dictionary format(.json) for saving.
func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": get_class_name(),
		"color": {
			"r": color.r,
			"g": color.g,
			"b": color.b,
			"a": color.a
		}
	}

# Load data from a dictionary format(.json) to resource(PenColorEntity).
func load_data(data: Dictionary) -> void:
	var color_data = data.get("color", {})
	if color_data:
		color = Color(color_data.get("r", 1.0), 
					 color_data.get("g", 1.0), 
					 color_data.get("b", 1.0), 
					 color_data.get("a", 1.0))
					

func _on_value_updated_from_editor(item: TreeItem) -> void:
	var new_color := item.get_custom_bg_color(1)
	color = new_color

func config_editor_tree_item(item: TreeItem) -> void:
	item.set_text(0, "Pen Color")
	item.set_cell_mode(1, TreeItem.CELL_MODE_CUSTOM)
	#item.set_button_color(1, 1, color)
	#var texture = AtlasTexture.new()
	#var texturen = 
	#texture.atlas = preload("uid://jws2w5wpfvw7")
	#texture.region.position = Vector2(0, 0)
	#texture.region.size = Vector2(50, 50)
	#item.add_button(1, texture, 0)
	item.set_custom_as_button(1, true)
	#item.set_button(1, 1, ColorPickerButton.new())
	#item.set_
	var stylebox := StyleBoxFlat.new()
	#stylebox.set_content_margin_all(4)
	stylebox.bg_color = color
	stylebox.set_border_width_all(4)
	stylebox.border_color = Color.BLACK
	item.set_custom_stylebox(1, stylebox)
	#item.set_custom_draw_callback(1, _on_editor_button_pressed)
	#item.set_custom_bg_color(1, color)
	#item.set_custom_as_button(1, true)
	#item.set_button_color(1, 0, color)

func _on_editor_button_pressed() -> void:
	#var popup := Pop
	#var color_picker := ColorPicker.new()
	#print((item.get_custom_stylebox(1) as StyleBoxFlat).bg_color)
	pass
	


# 13. private methods: define all private methods here, use _ as preffix

# 14. subclasses: define all subclasses here
