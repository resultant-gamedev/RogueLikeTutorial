extends 'Base.gd'
# Player initial state when turn begins.
#
# It is the entry point when the turn begins and handles the user input by setting the next state
# as appropriate.


func enter(entity):
	"""Allow `_input` handling but no `_fixed_process`.

	Notes
	-----
	See `Base.enter` for more details.
	"""
	entity.set_fixed_process(false)
	entity.set_process_input(true)


func input(entity, event):
	"""Handle user input, set-up and transition to appropriate state based on user input.

	Notes
	-----
	See `Base.input` for more details.
	"""
	var delta_xy  # variable that will store a unit vector pointing in the appropriate direction based on user input
	if event.is_action_pressed('ui_right'):
		delta_xy = entity.UNIT_RIGHT
	elif event.is_action_pressed('ui_down'):
		delta_xy = entity.UNIT_DOWN
	elif event.is_action_pressed('ui_left'):
		delta_xy = entity.UNIT_LEFT
	elif event.is_action_pressed('ui_up'):
		delta_xy = entity.UNIT_UP
	if event.is_action_pressed('ui_right') or event.is_action_pressed('ui_down') \
	   or event.is_action_pressed('ui_left') or event.is_action_pressed('ui_up'):
		var state = self.__parent.get_node('Moving')
		state.delta_xy = delta_xy  # update the direction information on the `Moving` state before transitioning to it
		entity.transition_to(state)