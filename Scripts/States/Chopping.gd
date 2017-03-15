extends 'Base.gd'


export var energy_cost = 5
onready var __sample_player = self.get_node('/root/Game/SamplePlayer')
var __time
var __time_total


func enter(entity):
	"""Initialize starting values for time and calcualte duration for animation.

	Notes
	-----
	See `Base.enter` for more details.
	"""
	entity.set_process_input(false)
	entity.set_fixed_process(true)
	self.__sample_player.play('chop%02d' % int(rand_range(1, 3)))
	var animation_name = 'chop'
	entity.play(animation_name)
	var sprite_frames = entity.get_sprite_frames()
	var frame_count = sprite_frames.get_frame_count(animation_name)
	var animation_speed = sprite_frames.get_animation_speed(animation_name)
	self.__time = 0
	self.__time_total = frame_count/animation_speed


func update(entity, delta_time):
	"""This is called in `_fixed_process` and will transition to the idle state after finishing the animation.

	Notes
	-----
	See `Base.enter` for more details.
	"""
	self.__time += delta_time
	if self.__time >= self.__time_total:
		if entity.is_in_group('player'):
			entity.energy -= self.energy_cost
		entity.transition_to(self.__parent.get_node('Inactive'))
