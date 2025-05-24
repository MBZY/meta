extends CanvasLayer
class_name TalkLayer
@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit
@onready var talk_panel: HBoxContainer = $TalkPanel

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("ui_text_submit") and line_edit.is_editing()):
		text_submit()
		line_edit.text = ""
		talk_panel.hide()
	if(event.is_action_pressed("TALK") and not line_edit.is_editing()):
		talk_panel.visible = not talk_panel.visible
	
	pass
func text_submit():
	gmng.player.speak.rpc(line_edit.text)
	pass
