extends Control

const JP_SPACE: String = "　" # full-width space character

@export var text: String = ""
@export var furigana_text_size: int = 32
@export var regular_text_size: int = 64

var word_scene: Resource = preload("res://word.tscn")

func _ready() -> void:
	if text == "":
		return

	# Split text into words, while collecting furigana. A word is a single
	# character, or group of Kanji unless the Kanji is broken up by a brace.

	var words: Array[Dictionary] = []

	var _is_furigana = false
	var _is_kanji_word = false
	var furigana = ""
	var kanji_word = ""

	for i in text:
		if i == "{":
			_is_furigana = true
			if _is_kanji_word:
				_is_kanji_word = false
				print("End of kanji word")
				words.append({"furigana": "", "word": kanji_word})
				print(words)
				kanji_word = ""
			continue
		elif i == "}":
			print("End of furigana word")
			_is_furigana = false
			words[words.size()-1].furigana = furigana
			print(words)
			furigana = ""
			continue
		elif _is_furigana:
			print("Added furigana char: " + i)
			furigana += i
			continue

		if is_kanji(i):
			_is_kanji_word = true
			print("Added kanji char: " + i)
			kanji_word += i
			continue
		elif _is_kanji_word:
			_is_kanji_word = false
			print("End of kanji word")
			words.append({"furigana": "", "word": kanji_word})
			kanji_word = ""
		else:
			print("Append char as word: " + i)
			words.append({"furigana": "", "word": i})


	print({"allwords": words})

	# Render

	for i in words:
		var new_word: Word = word_scene.instantiate()
		if i.furigana == "":
			i.furigana = JP_SPACE # take up some vertical space
		new_word.chars = i.word
		new_word.furigana = i.furigana
		new_word.furigana_text_size = furigana_text_size
		new_word.regular_text_size = regular_text_size
		$FlowContainer.add_child(new_word)

func is_kanji(c: String) -> bool:
	if c.length() == 0:
		return false
	var codepoint = c.unicode_at(0)
	return (codepoint >= 0x4E00 and codepoint <= 0x9FFF) or \
		   (codepoint >= 0x3400 and codepoint <= 0x4DBF) or \
		   (codepoint >= 0x20000 and codepoint <= 0x2A6DF)
