extends StreamPlayer


func _ready():
	self.set_stream(preload('res://Assets/Audio/music.ogg'))
	self.set_loop(true)
	self.play()