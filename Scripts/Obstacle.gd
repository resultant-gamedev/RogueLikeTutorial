extends "Area2D.gd"


const SPRITE_PATH = 'res://Assets/Sprites/TileSet/%s%s.png' # path string to sprite which needs to be formatted
export var sprite = '' # set in the `Inspector` panel for each node under `TileSet/Obstacles`
export var hp = 3 # hit points of this bush (can be different for different obstacles)
onready var __pos_start = self.parent.get_pos()
var __sprite_damage_set = false # keep track if the sprite has been changed when attached by the player
var __time = 0
var __time_total = 0.1
var __amplitude = 3 # displacement range for the shake animation


func take_damage(damage):
	"""Decrease `hp` based on `damage` or remove obstacles from the scene tree if `hp` reaches 0.

	Parameters
	----------
	damage: number
		The `damage` taken by the obstacle (subtracted from `hp`)
	"""
	self.set_process(true)
	self.__time = 0
	self.hp -= damage
	if self.hp <= 0:
		self.parent.queue_free()
	if not self.__sprite_damage_set:
		# if it's the first time the player attacks the bush then change the sprite
		self.parent.set_texture(load(SPRITE_PATH % [self.sprite, '_dmg']))


func _ready():
	self.parent.get_texture().load(SPRITE_PATH % [self.sprite, ''])


func _process(delta_time):
	self.__time += delta_time
	# each frame move the parent in a different place, close to current position (`__pos_start`), based on
	# `__amplitude` and random values
	self.parent.set_pos(self.__pos_start + Vector2(randf(), randf()) \
	                    * 2 * self.__amplitude - Vector2(1, 1) * self.__amplitude)
	if self.__time >= self.__time_total:
		self.parent.set_pos(self.__pos_start)
		self.set_process(false)