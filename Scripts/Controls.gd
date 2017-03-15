extends Container


func _on_Left_pressed():
	var ev = InputEvent()
	ev.type = InputEvent.ACTION
	# set as move_left, pressed
	ev.set_as_action("ui_left", true)
	# feedback
	get_tree().input_event(ev)


func _on_Up_pressed():
	var ev = InputEvent()
	ev.type = InputEvent.ACTION
	# set as move_left, pressed
	ev.set_as_action("ui_up", true)
	# feedback
	get_tree().input_event(ev)


func _on_Right_pressed():
	var ev = InputEvent()
	ev.type = InputEvent.ACTION
	# set as move_left, pressed
	ev.set_as_action("ui_right", true)
	# feedback
	get_tree().input_event(ev)
	
func _on_Down_pressed():
	var ev = InputEvent()
	ev.type = InputEvent.ACTION
	# set as move_left, pressed
	ev.set_as_action("ui_down", true)
	# feedback
	get_tree().input_event(ev)
