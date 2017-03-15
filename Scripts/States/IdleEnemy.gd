extends 'Base.gd'
# Player initial state when turn begins.
#
# It is the entry point when the turn begins and handles the user input by setting the next state
# as appropriate.

const EPSILON = 1e-8  # small number used in float arithmetic


func enter(entity):
	"""Here is the brain of the enemy AI basically.

	In the idle state we have the algorithm for determining the direction of movement of the AI.
	Every other state is exactly the same! How cool is that? This does nothing by itself, it doesn't
	actually move the enemy on screen, it just chooses a direction and then delegates to the `Moving`
	state, exactly like in the `IdlePlayer` state, except it's determined automatically by the computer.
	Nice!

	It's a very simple process, the AI will favor the horizontal movement and once it is aligned with the
	`Player` then it moves vertically. It's very basica, it doesn't care about obstacles or anything like
	that. Something like this would definitely be somewhat "stupid" algorithm. But using more advanced
	techniques (such as A* and so on) is outside of the scope of this tutorial series. Feel
	free to explore tho'!

	Notes
	-----
	See `Base.enter` for more details.
	"""
	var delta_xy  # variable that will store a unit vector pointing in the appropriate direction based on user input
	var player = entity.get_node('../Player')  # the AI needs to know the location of the `Player`, so get the node here
	var player_pos = player.get_pos()
	var self_pos = entity.get_pos()
	# first see if AI & `Player` are aligned, and if so do tests on Y axis
	if abs(self_pos.x - player_pos.x) < EPSILON:
		# if the AI is located lower on the Y axis then move down (NOTE remember that "top" in Godot's coordinates is
		# down in screen coordinates!) else move up
		if self_pos.y < player_pos.y:
			delta_xy = entity.UNIT_DOWN
		else:
			delta_xy = entity.UNIT_UP
	else:
		# if the AI is not aligned on the Y axis then move towards the `Player` horizontally
		if self_pos.x < player_pos.x:
			delta_xy = entity.UNIT_RIGHT
		else:
			delta_xy = entity.UNIT_LEFT
	# once the direction is determined (`delta_xy`) then update it in the `Moving` state, just like in `IdlePlayer`
	var state = self.__parent.get_node('Moving')
	state.delta_xy = delta_xy  # update the direction information on the `Moving` state before transitioning to it
	entity.transition_to(state)