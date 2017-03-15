extends Area2D


export var scale = 1.0  # value for scaling the collision shape from the `Inspector`
onready var parent = self.get_node('..')
onready var __board = self.get_node('/root/Game/Board')  # we need this to get `tile_size` to calculate
                                                         # dimensions dynamically
onready var __actors = self.__board.get_node('Actors')
onready var __sample_player = self.get_node('/root/Game/SamplePlayer')


func take_damage(damage):
	"""The `Actors` should take damage when attacked. It goes both ways, for enemies and player alike.

	Parameters
	----------
		damage: number
			The damage amount.
	"""
	self.__sample_player.play('enemy%02d' % int(rand_range(1, 3)))  # play sound when actor is attacked
	self.parent.energy -= damage  # register the damage (lower `energy`)
	# now only if this is the AI it we'll remove it from the map, but this introduces a problem in the main loop!
	# NOTE that when we remove an enemy from the map, this is in the middle of the 'game loop' and we'll have
	# to take mesures to not call functions on the removed node! Check the `start()` function from `Game.gd`
	if self.parent.is_in_group('enemy') and self.parent.energy <= 0:
		self.parent.queue_free()


func _ready():
	self.__set_shape()


func __set_shape():
	"""Sets the collision shape dimensions based on `tile_size`.
	"""
	var dimension = self.__board.tile_collection.tile_size * 0.5  # this will be (16, 16), exactly the amount
	                                                              # we need to displace the `Area2D` node to position
	                                                              # it in the center of the tile
	self.set_pos(dimension)  # set origin to center of tile
	# first get the child node, and then get the `Shape` resource (the property from the `Inspector`)
	# and on that resource set the `Extents` property to `dimension`
	self.get_node('CollisionShape2D') \
	    .get_shape() \
	    .set_extents(dimension * scale)