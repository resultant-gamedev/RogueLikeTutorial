extends 'Base.gd'
# This state essentially does nothing except turn off `_input` handling and `_fixed_process`
#
# Turnins off `_input` handling and `_fixed_processing` on the given `entity`. This means that no further interaction
# will be possible with this `entity`.


func enter(entity):
	"""Turns off `_input` and `_fixed_process` making `entity` inactive.

	Notes
	-----
	See `Base.input` for more details.
	"""
	entity.set_fixed_process(false)
	entity.set_process_input(false)
	entity.play('idle')
	entity.emit_signal('turn_end')  # note that we emit the 'turn_end' signal when `entity` becomes inactive