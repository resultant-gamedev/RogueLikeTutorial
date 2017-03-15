extends "Area2D.gd"


func _ready():
	self.connect('area_enter', self, '__on_area_enter')


func __on_area_enter(area):
	var area_parent = area.get_node('..') # get the parent of the colliding `Area2D`
	if area_parent.is_in_group('player'): # if this parent is in the `player` group
		Globals.set('player_energy', area_parent.energy) # save the `energy` value
		self.get_tree().reload_current_scene() # finally reload the current scene
