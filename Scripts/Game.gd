extends Node


export var window_zoom = 1
var __enemy_turn_skip = false  # we'll make the enemy skip every second turn to give the player a fair advantage
onready var __board = self.get_node('Board')
onready var __actors = self.get_node('Board/Actors')


func _ready():
	"""Exposed function that gets called automatically when this node (and all of its children) enter the active scene.

	This function is the perfect place for setting up internal variables and doing initializations because
	at the point this function gets triggered, the node and all of its children are already in the active scene
	so this is when it's safe to access other nodes from the scene (as oposed to say the `_init` function
	which gsts triggered when the object is created). In this case we use it to creat the game board and set the
	window size.
	"""
	randomize() # reset the random seed each game so we get different random sequences
	self.__board.fetch_tiles('res://Scenes/TileSet.tscn', 'Exit')
	self.__board.make_board()
	self.__set_screen()
	self.start()  # <- start the main game look right here after we set everything else up


func start():
	"""The main "game loop".

	This function goes through all of the characters and "activates" each of them in turn. This is achieved
	through the use of the `yield()` statement. `yield(object, signal)` suspends the function at this exact location
	but without actually returning frmo the function. It just patiently waits for the emitted signal and when it receives
	it, the function resumes and it will continue running. So now we place this `yield()` inside an intifinite loop and to
	do something like this:
		1. call set-up function on character (here called `actor.activate()`
		2. call `yield()`, suspend & wait for signal to be emitted. This gives time for the player for example to think
		   and after he's done with the move, we emit the signal in that object (in our case `turn_end`) and afterwards the
		   loop starts again
	Each loop through the actors we check if the enemy is able to move or not and every outer loop we invert `self.__enemy_turn_skip`
	to get the enemies to skip every second turn.

	That's pretty much all there is to it.
	"""
	while true:
		# remember that we are adding the `Player` last to the `Board` node (see `Board.gd`) so in order for the player to play
		# first we need to invert the array. Can you think of a better way of doing it?!
		var actors = self.__actors.get_children()
		actors.invert()
		for actor in actors:
			# NOTE the `weakref` here is the only way I could find on how to deal with the problem of removing enemies (deleting nodes)
			# while peforming the loop. As far as I know there's no way to check if a node has been removed, so `weakref` is a
			# workaround. It creates (as the name implies) a weak reference to the given object and when you try getting the
			# reference back (with `get_ref`) it will return `null` as the deleted node is nowhere to be found, so we can use
			# this to check if an enemy has been removed from the board and if so skip it.
			if weakref(actor).get_ref() \
			   and (actor.is_in_group("player") \
			        or (actor.is_in_group("enemy") and not self.__enemy_turn_skip)):
				actor.activate()
				yield(actor, 'turn_end')
		self.__enemy_turn_skip = not self.__enemy_turn_skip


func __set_screen():
	"""Helper function to set-up the behaviour of the game window and viewport.

	We will set a window size which is dynamic, based on how many tiles we have on `x` and `y`. We also instruct
	Godot to stretch the viewport so that it occupies as much space as possible in the game window, but retaining the
	aspect ratio so that the sprites won't be stretched independently on `x` or `y`.
	"""
	var board_size = (2 * (self.__board.perim_thickness + Vector2(1, 1)) \
	                 + self.__board.inner_grid_size) * self.__board.tile_collection.tile_size  # size of the board in pixels
	self.get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, \
	                                   SceneTree.STRETCH_ASPECT_KEEP, board_size)  # set the strech behavior explained earlier
	OS.set_window_size(self.window_zoom * board_size)  # set the window size to `self.window_zoom` times the board size in pixels


func _on_Yes_pressed():
	get_node("DeadPanelNode").hide()
	self.get_tree().reload_current_scene()


func _on_No_pressed():
	pass # replace with function body
