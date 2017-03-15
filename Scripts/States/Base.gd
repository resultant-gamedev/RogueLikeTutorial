extends Node
# This is a base state that defines common variables and the method 'interfaces'
#
# The methods don't actually do anything because this class isn't meant to be used directly. Its purpose is to
# be extended by nodes that will become usable states. Why? Because not all states (as you shall see) require
# to implement functionality for all of these methods. But the methods need to exist, even if they don't do anything
# as they will be called in the actor's `_input` and `_fixed_process` functions.


onready var __parent = self.get_node('..')


func enter(entity):
	"""This method is the entry point after each state transition and is called each time after state transitions happen.
	"""
	pass


func input(entity, event):
	"""This will handle the input if needed, basically `_input` delegates to this function.

	Parameters
	----------
	entity: actor
		The `entity` to operate on.
	event: inputevent
		Is `_input`'s argument, which is passed in by Godot and has user input information.
	"""
	pass


func update(entity, delta_time):
	"""Called every physics frame to perform action.

	Parameters
	----------
	entity: actor
		The character or actor to operate on.
	delta_time: float
		Time step passed in from `_fixed_process`.
	"""
	pass