class_name Word
extends VBoxContainer

@export var chars: String
@export var furigana: String
@export var furigana_text_size: int = 32
@export var regular_text_size: int = 64
var color_override: Variant
var furigana_color_override: Variant

@onready var character_container: HBoxContainer = $HBoxContainer
@onready var furigana_label: RichTextLabel = $Furigana

func _ready() -> void:
	assert(character_container != null, "HBoxContainer node not found!")

	for i in chars:
		var new_label = Label.new()
		#new_label.scroll_active = false
		new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		new_label.clip_contents = false
		new_label.custom_minimum_size = Vector2(64, 64)
		new_label.text = i
		print("label size: " + str(regular_text_size))
		new_label.add_theme_font_size_override("font_size", regular_text_size)
		new_label.custom_minimum_size.x = regular_text_size

		#new_label.bbcode_enabled = true
		if color_override is Color:
			print("overriding color in word")
			new_label.add_theme_color_override("font_color", color_override)
			#new_label.push_color(color_override)
			#new_label.text = "[color=red]" + i + "[/color]"
		character_container.add_child(new_label)

	furigana_label.text = furigana
	furigana_label.custom_minimum_size.y = furigana_text_size
	print("furigana size: " + str(furigana_text_size))
	furigana_label.add_theme_font_size_override("normal_font_size", furigana_text_size)
	if furigana_color_override is Color:
		print("furigana color override")
		furigana_label.add_theme_color_override("default_color", furigana_color_override)
