extends Node

var tile_size = Vector2(128, 128)
onready var texture = $Sprite.texture

func _ready():
	var tex_width = texture.get_width() / tile_size.x
	var tex_height= texture.get_height() / tile_size.y
	var ts = TileSet.new()
	for x in range(tex_width):
		for y in range(tex_height):
			var region = Rect2(x * tile_size.x, y * tile_size.y,
							   tile_size.x, tile_size.y)
			var ctx = HashingContext.new()
			ctx.start(HashingContext.HASH_SHA256)
			var pba = PoolByteArray([0,x,0,y])
			ctx.update(pba)
			var id = ctx.finish()
			id = str(id.hex_encode())
			id = hash(id)
			ts.create_tile(id)
			ts.tile_set_texture(id, texture)
			ts.tile_set_region(id, region)
	ResourceSaver.save("res://terrain/terrain_tiles.tres", ts)
