tool

extends Node2D

export var texture: Texture = null setget set_texture, get_texture
var image: Image
export(float, 0.1, 1.0, 0.01) var fire_intensity : float = 0.7
export var palette = [ Color.red, Color8(152,34,7), Color8(250,240,21), Color8(249,187,11), Color8(248,137,9), Color8(0,0,0,140), Color8(0,0,0,48) ]
export var live_preview : bool = false setget set_live_preview, get_live_preview


func set_live_preview(value):
	live_preview = value
	if live_preview:
		$Timer.start()
	else:
		$Timer.stop()
		reset_image()
		update_texture()


func get_live_preview():
	return live_preview


func set_texture(value):
	texture = value
	if value != null:
		reset_image()
		update_texture()
	else:
		$Sprite.texture = null


func get_texture():
	return texture


func reset_image():
	image = Image.new()
	var width = texture.get_width() + 20
	var height = texture.get_height() + 48
	image.create(width, height, false, Image.FORMAT_RGBA8)
	image.lock()
	image.blit_rect(texture.get_data(), Rect2(Vector2.ZERO, texture.get_size()), Vector2(10, height - texture.get_height()))
	image.unlock()
	$Sprite.position.y = -(image.get_height() - texture.get_height()) / 2
	
	
func update_texture():
	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image, 0)
	$Sprite.texture = imageTexture


func _on_Timer_timeout():
	if texture == null:
		return
	
	image.lock()
	
	# A - Copy original texture over the fire image
	image.blit_rect_mask(texture.get_data(), texture.get_data(), Rect2(Vector2.ZERO, texture.get_size()), Vector2(10, image.get_height() - texture.get_height()))
	
	# B - Random selection of pixels
	var test_count = image.get_width() * image.get_height()
	for i in range(test_count):
		var x = randi() % image.get_width()
		var y = randi() % image.get_height()
		var color = image.get_pixel(x, y)
		if color.a > 0:
			# Get the palette index of the current pixel
			var color_index = -1
			for j in range(palette.size()):
				if abs(color.r8 - palette[j].r8) <= 1 and abs(color.g8 - palette[j].g8) <= 1 and abs(color.b8 - palette[j].b8) <= 1 and abs(color.a8 - palette[j].a8) <= 1:
					color_index = j
					break
			
			# C - Copy color in one of the pixel above the current one
			if y > 0 and randf() <= fire_intensity:
				var new_x = x + randi() % 3 - 1
				if new_x >= 0 and new_x < image.get_width():
					image.set_pixel(new_x, y - 1, color)
			
			# D - Update color of the current pixel
			if color_index >= 0 and color_index < (palette.size() - 1):
				image.set_pixel(x, y, Color(palette[color_index + 1]))
			else:
				image.set_pixel(x, y, Color.transparent)
					
	image.unlock()
	update_texture()
