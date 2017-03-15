extends 'Area2D.gd'  # pay atention, we're extending `Area2D.gd`! not `Area2D`


export var energy_restored = 20  # how much energy is replenished by picking up this object
onready var __animation_player = self.get_node('../AnimationPlayer')


func _ready():
	self.connect('area_enter', self, '__on_area_enter')  # whenever `Player` will be on top of this tile
	                                                     # `__on_area_enter` will be triggered
	randomize()


func __on_area_enter(player_area):
	"""Starts feedback animation and replenishes energy on `Player`.

	Parameters
	----------
	player_area: Area2D
		The only other object that can interact with this one is the `Player` `Area2D` object. That being the
		only possibility, I named this parameter `player_area`. This is provided by Godot whenever a collision is
		detected.
	"""
	self.__animation_player.play('pick-feedback')  # play feedback animation
	player_area.get_node('..').energy += self.energy_restored  # get parent node of `player_area` which is
	                                                           # the `Player` object in this case and
	                                                           # increase `Player.energy` with `self.energy_restored`
	self.__sample_player.play('%s%02d' % [self.get_groups()[0], int(rand_range(1, 3))])