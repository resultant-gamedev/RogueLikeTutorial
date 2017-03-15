extends 'Base.gd'
# The meaty part of the code that moves the character on the screen


export var energy_cost = 5  # cost per tile movement. This only affects `Player`
export var duration = 0.10  # how cool is this? Because states are just regular nodes (this inherits from `Inactive` which in turn
                            # inherits from `Node`) these states can have parameters that can be exported to the inspector panel
                            # just as regular nodes. Here for example I'm exporting the animation duration (how much time to take to
                            # move between grid points) so that it can be easily modified through the user interface
var __time_elapsed = 0  # keep track of elapsed time
var __pos_start  # store the starting position of the character
var delta_xy  # remember this one? It is set in the `IdlePlayer` state, this is how this state knows where to transition (in terms
              # of grid units)
onready var __board = self.get_node('/root/Game/Board')
onready var __sample_player = self.get_node('/root/Game/SamplePlayer')


func enter(entity):
	"""Initialize starting values for time and position and check for collisions.

	If no collision is detected then nothing happens and the movement takes place (and plays the SFX as well), otherwise we check
	if the collider is an obstacle or not, if it is then transition to the `Chopping` state which applies damage to the obstacle
	and starts the chop animation.

	Notes
	-----
	See `Base.enter` for more details.
	"""
	entity.set_process_input(false)
	entity.set_fixed_process(true)
	self.__time_elapsed = 0
	self.__pos_start = entity.get_pos()
	if entity.ray_casts[delta_xy].is_colliding():
		var collider = entity.ray_casts[delta_xy].get_collider()
		var state_name
		if (entity.is_in_group('player') and (collider.is_in_group('obstacle') or collider.parent.is_in_group('enemy'))) or \
		   (entity.is_in_group('enemy') and (collider.is_in_group('obstacle') or collider.parent.is_in_group('player'))):
			collider.take_damage(entity.damage)
			state_name = 'Chopping'
		elif entity.is_in_group('player'):
			state_name = 'IdlePlayer'
		elif entity.is_in_group('enemy'):
			self.delta_xy = Vector2(0, 0)
		if state_name:
			entity.transition_to(self.__parent.get_node(state_name))
	else:
		self.__sample_player.play('footsteps%02d' % int(rand_range(1, 3)))


func update(entity, delta_time):
	"""This is called in `_fixed_process` and will smoothly move the `entity` from current position to the position given by `self.delta_xy` (in grid units).

	Notes
	-----
	See `Base.enter` for more details.
	"""
	var delta_xy_px = self.delta_xy * self.__board.tile_collection.tile_size  # convert from grid units to pixels
	var pos = self.__pos_start.linear_interpolate(self.__pos_start + delta_xy_px, self.__time_elapsed/self.duration)
	if self.__time_elapsed > self.duration:
		pos = self.__pos_start + delta_xy_px  # after the move is complete we make sure that the location of the `entity` is set to be
		                                      # exactly on the next grid box so tiny rounding errors will be corrected with each move
		if entity.is_in_group('player'):
			entity.energy -= self.energy_cost
			if(entity.energy <= 0):
				get_node("/root/Game/DeadPanelNode").show()
		entity.transition_to(self.__parent.get_node('Inactive'))
	self.__time_elapsed += delta_time  # keep track of elapsed time
	entity.set_pos(pos)  # set the position to the new location with each update
