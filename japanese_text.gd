class_name JapaneseText
extends Control

signal rendered
signal text_changed

const JP_SPACE: String = "　" # full-width space character
const JP_UNDERSCORE: String = "＿" # full-width underscore character
const NO_HIDE = -1

@export var text: String = "" # initial value only, use set_text() for updates
@export var furigana_text_size: int = 32
@export var regular_text_size: int = 64
@export var horizontally_centered: bool = false # initial only
@export var vertically_centered: bool = false # initial only

var hide_kanji_word_index: int = NO_HIDE
var hide_furigana_word_index: int = NO_HIDE

var _kanji_words: Array[Dictionary] = []
var _text: String = ""

var word_scene: Resource = preload("res://addons/godot_japanese_text/word.tscn")

@onready var flow_container: FlowContainer = $CenterContainer/FlowContainer

func _ready() -> void:
	#set_text("Hello")
	render_text()

	flow_container.custom_minimum_size.x = $CenterContainer.size.x
	print($CenterContainer.size)

	flow_container.add_theme_font_size_override("default_font_size", regular_text_size)

	if not vertically_centered:
		$CenterContainer/FlowContainer.reparent(self)

	if not horizontally_centered:
		flow_container.alignment = FlowContainer.ALIGNMENT_BEGIN

	self_modulate.a = 0

func set_text(new_text: String) -> void:
	print("set_text called")
	text = new_text
	render_text()

func render_text() -> void:

	if text == "":
		return

	# Clear existing words

	for i in flow_container.get_children():
		flow_container.remove_child(i)

	# Split text into words, while collecting furigana. A word is a single
	# character, or group of Kanji unless the Kanji is broken up by a brace.

	var words: Array[Dictionary] = []

	var _is_furigana = false
	var _is_kanji_word = false
	var _is_special_word = false
	var furigana_word: String = ""
	var kanji_word: String = ""
	var special_word: String = ""
	var _kanji_index = 0
	print("Setting _kanji_words to empty")
	_kanji_words = []

	for i in text:
		if i == "{":
			print("Start of furigana word")
			_is_furigana = true
			continue
		elif i == "}":
			print("End of furigana word")
			_is_furigana = false
			words[words.size()-1].furigana = furigana_word
			print(words)
			furigana_word = ""
			continue
		elif i == "[":
			print("Start of kanji word")
			_is_kanji_word = true
			continue
		elif i == "]":
			print("End of word")
			_is_kanji_word = false
			_end_of_kanji(words, kanji_word, _kanji_index)
			kanji_word = ""
			continue
		elif _is_kanji_word:
			print("Added kanji char: " + i)
			kanji_word += i
			continue
		elif _is_furigana:
			print("Added furigana char: " + i)
			furigana_word += i
			continue
		else:
			# Just a normal character
			words.append({"furigana": JP_SPACE, "word": i})

		#if is_kanji(i):
			#_is_kanji_word = true
			#print("Added kanji char: " + i)
			#kanji_word += i
			#continue
		#elif _is_kanji_word:
			#_is_kanji_word = false
			#_end_of_kanji(words, kanji_word, _kanji_index)
			#kanji_word = ""
			#print("Append char as word: " + i)
			#words.append({"furigana": "", "word": i})
		#else:
			#print("Append char as word: " + i)
			#words.append({"furigana": "", "word": i})

	# At the end of the loop, if we haven't ended the kanji, end it automatically.
	#if _is_kanji_word:
		#_end_of_kanji(words, kanji_word, _kanji_index)

	print({"allwords": words})

	if not _kanji_words.is_empty() and hide_furigana_word_index != NO_HIDE:
		_kanji_words[hide_furigana_word_index].furigana = "???"
		_kanji_words[hide_furigana_word_index].furigana_color = Color.YELLOW

	if not _kanji_words.is_empty() and hide_kanji_word_index != NO_HIDE:
		var length = _kanji_words[hide_kanji_word_index].word.length()
		_kanji_words[hide_kanji_word_index].word = JP_UNDERSCORE.repeat(length)
		_kanji_words[hide_kanji_word_index].color = Color.YELLOW

	# Render

	for i in words:
		var new_word: Word = word_scene.instantiate()
		if i.furigana == "":
			i.furigana = JP_SPACE # take up some vertical space
		new_word.chars = i.word
		new_word.furigana = i.furigana
		new_word.furigana_text_size = furigana_text_size
		print("word size: " + str(regular_text_size))
		new_word.regular_text_size = regular_text_size
		if "color" in i:
			print("overriding color")
			new_word.color_override = i.color
		if "furigana_color" in i:
			new_word.furigana_color_override = i.furigana_color
		flow_container.add_child(new_word)

	rendered.emit()

func _end_of_kanji(words, kanji_word, _kanji_index) -> void:
	print("End of kanji word")

	var new_kanji_word: Dictionary = {}
	new_kanji_word.furigana = ""
	new_kanji_word.word = kanji_word

	_kanji_words.append(new_kanji_word)
	print({"kw":_kanji_words})
	print("Hide index: " + str(hide_kanji_word_index))
	print("Curr index: " + str(_kanji_words.size() - 1))
	if hide_kanji_word_index != NO_HIDE and _kanji_words.size() - 1 == hide_kanji_word_index:
		print("Hiding: " + str(hide_kanji_word_index))
		#kanji_word = "[color=red]" + JP_UNDERSCORE.repeat(kanji_word.length()) + "[/color]"
		kanji_word = JP_UNDERSCORE.repeat(kanji_word.length())
		new_kanji_word.color = Color.YELLOW
	words.append(new_kanji_word)
	kanji_word = ""

static func is_kanji(c: String) -> bool:
	if c.length() == 0:
		return false
	var codepoint = c.unicode_at(0)
	return (codepoint >= 0x4E00 and codepoint <= 0x9FFF) or \
		   (codepoint >= 0x3400 and codepoint <= 0x4DBF) or \
		   (codepoint >= 0x20000 and codepoint <= 0x2A6DF)

static func has_kanji(s: String) -> bool:
	for c in s:
		if is_kanji(c):
			return true
	return false

func get_kanji_words() -> Array[Dictionary]:
	return _kanji_words
