class_name Word
extends VBoxContainer

@export var chars: String
@export var furigana: String
@export var furigana_text_size: int = 32
@export var regular_text_size: int = 64

@onready var character_container: HBoxContainer = $HBoxContainer
@onready var furigana_label: RichTextLabel = $Furigana

func _ready() -> void:
	assert(character_container != null, "HBoxContainer node not found!")

	for i in chars:
		var new_label = RichTextLabel.new()
		new_label.scroll_active = false
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_label.clip_contents = false
		new_label.custom_minimum_size = Vector2(64, 64)
		new_label.text = i
		new_label.add_theme_font_size_override("normal_font_size", regular_text_size)
		new_label.custom_minimum_size.x = regular_text_size
		character_container.add_child(new_label)

	furigana_label.text = furigana
	furigana_label.custom_minimum_size.y = furigana_text_size
	furigana_label.add_theme_font_size_override("normal_font_size", furigana_text_size)
