extends AnimatedSprite
# This `Actor` (filename is `Actor.gd) class extends `AnimatedSprite` and is meant to be used for both player and enemies.
# Its purpose is to have an entry point for setting up the appropriate state when the turn begins.


signal turn_end  # this signal will be emitted when the character finishes the turn (at end of chop, move, etc.). When
                 # this happens, the `start()` function from `Game.gd` will resume and the new character will be activated
                 # this is a very simple way of making a turn base system
const UNIT_RIGHT = Vector2(1, 0)
const UNIT_DOWN = Vector2(0, 1)
const UNIT_LEFT = Vector2(-1, 0)
const UNIT_UP = Vector2(0, -1)
export var damage = 1 # damage that will be dealt to the obstacles (bushes)
export var energy = 100 # basically the life force of our `Actor`. When this reaches 0 on the `Player` the game is over
var __state # keep track of internal state
onready var ray_casts = {  # store ray casts based on their direction
	UNIT_RIGHT: self.get_node('RayCast2DRight'),
	UNIT_DOWN: self.get_node('RayCast2DDown'),
	UNIT_LEFT: self.get_node('RayCast2DLeft'),
	UNIT_UP: self.get_node('RayCast2DUp')
}
onready var __states = self.get_node('/root/Game/States')
onready var __area = self.get_node('Area2D')


func transition_to(state):
	"""Convenience function for setting the state.

	Parameters
	----------
	state: custom
		It sets the new state and it triggers the `enter` method of the state object.
	"""
	self.__state = state
	self.__state.enter(self)


func activate():
	"""Function called from `start()` (from `Game.gd`) to set up appropriate states for `Actors`.

	Here we are using some funky string formatting, because why not?! The line
	`var state_name = 'Idle%s' % self.get_groups()[0].capitalize()` is roughly equivalent to:

	```
	var state_name
	if self.is_in_group('player'):
		state_name = 'IdlePlayer'
	elif self.is_in_group('enemy'):
		state_name = 'IdleEnemey'
	```

	But it's much much simpler. It's worth knowing these things!
	"""
	if self.is_in_group('player'):
		print(self.energy)
		get_node("/root/Game/HealthPanel/HealthLabel").set_text(str(self.energy))
	var state_name = 'Idle%s' % self.get_groups()[0].capitalize()
	self.transition_to(self.__states.get_node(state_name))
	# just for some feedback we'll keep the following in to get to see the energy level
	# of the player each turn


func _ready():
	"""Set-up collision exceptions for ray casts on `self`.

	This is necessary because all of the enemies need to interact between themselves (they're on
	the same physics layer), but then it would be a problem as the ray casts will detect
	the a collision with `Area2D` under this object. We add exceptions to they ray casts
	on `Area2D` under `self` so that this won't happen.
	"""
	if Globals.has('player_energy') and self.is_in_group('player'):
		self.energy = Globals.get('player_energy')
	for key in self.ray_casts:
		self.ray_casts[key].add_exception(self.__area)


func _input(event):
	"""`_input` is delegating to the implementation from the states.
	"""
	self.__state.input(self, event)


func _fixed_process(delta_time):
	"""`_fixed_process` is delegating to the implementation from the states.
	"""
	self.__state.update(self, delta_time)
