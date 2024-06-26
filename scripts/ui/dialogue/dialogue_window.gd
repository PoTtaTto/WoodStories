extends CanvasLayer
class_name DialogueWindow
## Script handles the display of dialogue text with a typing effect, along with speaker icons for left and right sides

## Defines the rate at which characters in the dialogue text are revealed.
const CHAR_READ_RATE: float = 0.05
## Defines the waiting time before hiding the dialog, when all the text will be displayed
const END_WAIT_TIME: float = 1.0
## Transparency value for inactive speakers to distinguish between active and inactive speakers.
const INACTIVE_SPEAKER_TRANSPARENCY: float = 0.4

## Holds the container node for the textbox.
@onready var textbox_container: MarginContainer = $TextboxContainer

## References to the symbols indicating the start of dialogue text.
@onready var start_symbol: Label = $TextboxContainer/MarginContainer/HBoxContainer/start
## References to the symbols indicating the end of dialogue text.
@onready var end_symbol: Label = $TextboxContainer/MarginContainer/HBoxContainer/end

## Reference to the label node where dialogue text is displayed.
@onready var label: Label = $TextboxContainer/MarginContainer/HBoxContainer/Label

## References to the speaker nodes on the left.
@onready var speaker_left: Sprite2D = $speaker_left
## References to the speaker nodes on the right.
@onready var speaker_right: Sprite2D = $speaker_right

## References to the audio stream 2d node
@onready var left_speaker_audio: AudioStreamPlayer2D = $left_audio
@onready var right_speaker_audio: AudioStreamPlayer2D = $right_audio


## Enum to determine the side of the speaker in the dialogue.
enum SpeakerSides {
	LEFT,  ## Indicates the speaker is on the left side.
	RIGHT  ## Indicates the speaker is on the right side.
}

## Signal emitted when the dialogue has finished displaying.
signal dialogue_finished


## Removes the dialogue display, including speakers, text, and the textbox itself.
func remove_dialogue() -> void:
	_remove_speakers()
	_remove_text()
	_remove_textbox()
	left_speaker_audio.stop()
	right_speaker_audio.stop()
	dialogue_finished.emit()


## Prepares and shows the dialogue by configuring speakers and text display.
## @param speaker_left Path for the left speaker's texture.
## @param speaker_right Paath for the right speaker's texture.
## @param text The dialogue text to display.
## @param is_left_active Boolean indicating if the left speaker is active.
func show_dialogue(dialogue: Dialogue) -> void:
	_show_textbox()
	
	if dialogue.is_left_active:
		left_speaker_audio.play()
		_show_speaker(dialogue.speaker_left, SpeakerSides.LEFT, true)
		_show_speaker(dialogue.speaker_right, SpeakerSides.RIGHT, false)
	else:
		right_speaker_audio.play()
		_show_speaker(dialogue.speaker_left, SpeakerSides.LEFT, false)
		_show_speaker(dialogue.speaker_right, SpeakerSides.RIGHT, true)
		
	_show_text(dialogue.text)

## Hides the speaker icons.
func _remove_speakers() -> void:
	speaker_left.hide()
	speaker_right.hide()

## Clears the dialogue text and symbols.
func _remove_text() -> void:
	label.visible_characters = 0
	start_symbol.text = ''
	end_symbol.text = ''
	label.text = ''

## Hides the textbox container.
func _remove_textbox() -> void:
	textbox_container.hide()


## Shows the specified speaker's icon and sets its active state.
## @param role Identifier for the speaker's role, used to load the correct sprite.
## @param side The side (LEFT or RIGHT) where the speaker's icon should be placed.
## @param is_active Boolean indicating if the speaker is actively speaking.
func _show_speaker(role, side: SpeakerSides, is_active: bool = true) -> void:
	var sprite = null
	
	# If there https request then role is float, that's why we translate it to enum
	match role:
		'MAIN':
			sprite = load("res://assets/characters/main/main_dialogue.png")
		'WIZARD':
			sprite = load("res://assets/characters/wizard/wizard_dialogue.png")
		'NECROMANCER':
			sprite = load('res://assets/characters/necromancer/necromancer_dialogue.png')
		'KNIGHT':
			sprite = load("res://assets/characters/knight_woman/knight_woman_dialogue.png")
		_:
			sprite = null
	
	var current_speaker = null
	match side:
		SpeakerSides.LEFT:
			speaker_left.texture = sprite
			current_speaker = speaker_left
		SpeakerSides.RIGHT:
			current_speaker = speaker_right
			speaker_right.texture = sprite
	
	current_speaker.show()	
	if not is_active:
		current_speaker.modulate.a = INACTIVE_SPEAKER_TRANSPARENCY

## Begins the process of showing the dialogue text with a typing effect.
## @param text The dialogue text to display.
func _show_text(text: String) -> void:
	start_symbol.text = '*'
	label.text = text
	
	var tween = create_tween()
	tween.tween_property(label, 'visible_characters', len(text), CHAR_READ_RATE * len(text))
	tween.finished.connect(_on_text_tween_finished)
	

## Signifies the end of the text reveal and triggers a close timer.
func _on_text_tween_finished():
	end_symbol.text = 'v'
	left_speaker_audio.stop()
	right_speaker_audio.stop()		
	_start_close_timer()

## Starts a timer for automatically closing the dialogue box after a brief pause.
func _start_close_timer():
	var timer = Timer.new()
	timer.wait_time = END_WAIT_TIME
	timer.one_shot = true
	timer.connect("timeout", _on_close_timer_timeout)
	add_child(timer)
	timer.start()

## Callback for the timer's timeout signal. Removes the dialogue display.
func _on_close_timer_timeout():
	remove_dialogue()

## Displays the textbox container.
func _show_textbox() -> void:
	textbox_container.show()

## Prepares the dialogue UI by clearing any existing dialogue on ready.
func _ready():
	remove_dialogue()
