extends Node


export var inner_grid_size = Vector2(8, 8)  # represents the inner grid size for `x` & `y` (in units of tiles)
                                            # it doesn't need to be necessarily suare
export var perim_thickness = Vector2(1, 1)  # the inner perimeter thickness (in units of tiles)
export var count_obstacles = Vector2(2, 7)  # bounds for the (random) number of obstacles
export var count_items = Vector2(3, 6)  # same as above for items
export var count_enemies = Vector2(2, 2)  # same as above for enemies
var tile_collection  # will be an object holding the nodes from the `TileSet` scene which we will
                     # duplicate and add to this scene. It will also contain the size of the tiles
var __grid  # will be an array that will contain the available locaions (in units of tiles)
            # for placing the obstacle, item and enemy tiles
onready var actors = self.get_node('Actors')


func fetch_tiles(tile_set_filepath, size_node_name):
	"""Fetches the tiles from the `TileSet` and also their size.

	It populates the `self.__tile_collection` dictionary with another dictionary, on key
	'item' and the size property of a particular static sprite.  In our case we're going
	to use the `TileSet/Exit` node.

	Parameters
	----------
	tile_set_filepath: string
		The filepath to the `TileSet` scene (eg.: `res://Scenes/TileSet.tscn`) including
		the extension
	size_node_name: string
		The name of the child node of `TileSet` that is to be used to retreive the
		size of the tiles
	"""
	self.tile_collection = TileCollection.new()  # initialize the `self.tile_collection` member variable
	                                               # see line 173 for its definition
	var tile_set = load(tile_set_filepath).instance()  # load and instantiate the `TileSet` scene
	# the following for takes advantage of the hierachy we have set-up in the `TileSet`. This makes
	# things so much neater!
	for node in tile_set.get_children():  # for each node in the root node (`TileSet`), eg. `TileSet/Obstacles`
		self.tile_collection.item[node.get_name().to_lower()] = node  # save it for later use in the `self._tiles.is` dictionary
	self.tile_collection.tile_size = (tile_set \
	                                   .get_node(size_node_name) \
	                                   .get_texture() \
	                                   .get_size())  # also save the size of a tile based on the texture size from the node
	                                                 # referred to by the `size_node_name` parameter in `TileSet`


func make_board():
	"""Generate the board by adding nodes from `TileSet` to this node.
	"""
	randomize()  # this tells Godot to initialize the random seed so that each time we start a
	             # new game, the
	self.__grid = self.__make_grid()  # make an array of available places to put obstacles, items & enemies
	self.__add_base_tiles()  # call the function that adds the base nodes (impassable walls & the floors)
	# next we use the `self.__add_other_tiles` generic function (defined at line 108) to add the remaining tiles
	self.__add_other_tiles(self.tile_collection.item.obstacles, self, count_obstacles) # obstacles
	self.__add_other_tiles(self.tile_collection.item.items, self, count_items)  # items
	self.__add_other_tiles(self.tile_collection.item.enemies, self.actors, count_enemies)  # enemies
	# manually add the exit and player tiles at pre-defined locations, namely the top right corner
	# for the exit (in the outer perimeter) and the lower left corner for the player (in the same outer perimeter)
	self.__add_tile(self.tile_collection.item.exit, self, Vector2(self.inner_grid_size.x, -1))  # exit
	self.__add_tile(self.tile_collection.item.player, self.actors, Vector2(-1, self.inner_grid_size.y))  # player


func __make_grid():
	"""Creates an array with available locations for placing tiles based on `self.xys` dimensions.

	Returns
	-------
	grid: array of vector2
		Available locations as `Vector2`.
	"""
	var grid = []
	for x in range(self.inner_grid_size.x):
		for y in range(self.inner_grid_size.y):
			grid.push_back(Vector2(x, y))
	return grid


func __add_base_tiles():
	"""Addsa the outer impassable walls and the floors to the board.
	"""
	var bounds = {
		xmin = -self.perim_thickness.x - 1, xmax = self.inner_grid_size.x + self.perim_thickness.x,
		ymin = -self.perim_thickness.y - 1, ymax = self.inner_grid_size.y + self.perim_thickness.y
	}  # these represent the outer extremities of the board (in units of tiles) relative to
	   # the inner grid based on `self.perim_thickness`
	for x in range(bounds.xmin, bounds.xmax + 1):  # iterate over rows
		for y in range(bounds.ymin, bounds.ymax + 1):  # and then columns
			var tile  # helper variable to store which type of tile to add to the scene
			if (x == bounds.xmin or x == bounds.xmax or y == bounds.ymin or y == bounds.ymax):
				# if we are on the outer edge of the board then select a random wall tile
				tile = self.__rand_tile(self.tile_collection.item.walls)
			else:
				# else select a random floor tile
				tile = self.__rand_tile(self.tile_collection.item.floors)
			self.__add_tile(tile, self, Vector2(x, y))  # finally add it to the appropriate location


func __add_other_tiles(tile_set, parent, count=Vector2(1, 1)):
	"""Add other types of tiles (i.e. not walls or floors).

	Add random tiles to the inner grid from among the children of the node `tile_set`.
	A random number (between `count.x` and `count.y`, non-inclussive) of tiles will be added.

	Parameters
	----------
	tile_set: node
		A node that has other children nodes which will be used as tiles
	parent: node
		A node under which `tile_set`'s children will be added
	count: vector2
		Used to generate a random (integer) number between `count.x` and `count.y` (non-inclussive).
		This will be the number of tiles added to the inner board

	Notes
	-----
	The `count` parameters is set to the default value [1, 1] in the function signature. This way we can omit it during
	a function call if we want. This doesn't have any specific purpose other than to exemplify this fact.
	"""
	var n = int(rand_range(count.x, count.y))  # generate a random number between `count.x` and `count.y - 1`
	                                           # and convert it to an integer
	for i in range(n):
		# as long as there's something to add
		var idx = int(rand_range(0, self.__grid.size()))  # get a random index from the `self.__grid` array to pick a location
		var xy = self.__grid[idx]  # pick that location
		var tile = self.__rand_tile(tile_set)  # get a random tile from `tile_set`'s children
		self.__add_tile(tile, parent, xy)  # add the tile to the approrpiate location
		self.__grid.remove(idx)  # remove that location from `self.__grid` so we won't use it any longer


func __add_tile(tile, parent, xy):
	"""Adds a tile to this scene at the specified location (in units of tile size).

	Parameters
	tile: node
		The tile to be added to this scene
	parent: node
		A node under which `tile` will be added
	xy: vector2
		The location where to place it (in units of tile size)
	"""
	var tile_dup = tile.duplicate()  # first duplicate the given tile
	tile_dup.set_pos((self.perim_thickness + Vector2(1, 1) + xy) * self.tile_collection.tile_size)  # next set it's position to the appropriate location
	parent.add_child(tile_dup)  # and finally add it to the scene as a child of this node


func __rand_tile(tile_set):
	"""Given a parent node `tile_set`, select at random a child node and return it.

	Parameters
	tile_set: node
		A node that has children nodes to be used as tiles.
	"""
	var tiles = tile_set.get_children()  # get an array with the children of `tile_set`
	var r = int(rand_range(0, tiles.size()))  # generate a random number between [0, `tiles.size()`]
	return tiles[r]  # return the child node based on the random number


class TileCollection:
	var item = {}  # each item in this dictionary will be either a collection of nodes (a node of type `Node` and
	               # children `Sprite`/`AnimatedSprite` nodes) or the `Sprite`/`AnimatedSprite` nodes directly. It will
	               # then be used to place these sprites on the board by randomly picking a tile from the collection of nodes
	               # or by accesing directly the approriate tile, like the `Player` tile for example
	var tile_size  # this will hold the image size (which should be the same for all tiles), so basically the tile size
