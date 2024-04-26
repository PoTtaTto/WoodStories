extends Node
## This class serves as a manager for dialog boxes, handling the queue and display of dialog data.


## Stores an array of dictionaries, each representing the data for a single dialogue.
var dialogue_queue: Array[Dictionary] = []

## Represents the possible states of the Dialogue Manager.
enum State {
	DISPLAY_DIALOGUES, ## State when dialogues are being displayed.
	NO_DIALOGUES ## State when there are no dialogues to display.
}

## Holds the current state of the dialogue manager.
var current_state: State = State.NO_DIALOGUES

## Defines a signal to indicate that all dialogues in the queue have been finished.
signal all_dialogues_finished


## Adds a dialogue's data into the dialogue_queue array for future display.
## @param dialogue_data Dictionary containing the necessary data to display a dialogue.
func add_to_queue(dialogue_data: Dictionary) -> void:
	dialogue_queue.append(dialogue_data)

## Initiates the sequence of displaying all dialogues stored in the dialogue_queue.
func start_dialogues():
	if not _is_queue_empty():
		_play_next()


## Proceeds to display the next dialogue in the queue by loading and showing the dialogue window.
## It pops the front item from the dialogue queue and initiates its display.
func _play_next():
	var data = dialogue_queue.pop_front()
	var dialogue = load("res://prefabs/interface/dialogue_window.tscn").instantiate()
	add_child(dialogue)
	dialogue.show_dialogue(
		data['speaker_left'], data['speaker_right'],
		data['text'], data['is_left_active']
	)
	dialogue.connect('dialogue_finished', _on_dialogue_finished)

## Checks if the dialogue queue is empty. If so, emits the 'all_dialogues_finished' signal.
## @return bool True if the queue is empty, false otherwise.
func _is_queue_empty() -> bool:
	if len(dialogue_queue) == 0:
		emit_signal('all_dialogues_finished')
		return true
	return false

## Callback function called when a dialogue finishes displaying.
## It checks if there are more dialogues to display and continues the dialogue sequence if so.
func _on_dialogue_finished():
	if not _is_queue_empty():
		_play_next()
