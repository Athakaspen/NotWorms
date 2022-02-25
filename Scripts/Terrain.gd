extends Node2D

var destructible = preload("res://SubScenes/Terrain/Destructible.tscn")

# Used to automaticallt chunkify terrain on debug map
export var chunkify_on_load := false

func _ready() -> void:
	if chunkify_on_load: chunkify_terrain()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# The basis of this was taken from the Destructable Terrain demo
func clip(source_body: StaticBody2D, neg_poly: CollisionPolygon2D) -> void:
	var offset_poly = Polygon2D.new()
	# Transform the polygon values to take into account the transform
	offset_poly.polygon = neg_poly.global_transform.xform(neg_poly.polygon)
	
	var source_poly = source_body.get_node("RenderPoly")
	
	var result = Geometry.clip_polygons_2d(source_poly.polygon, offset_poly.polygon)
	
	if (len(result)) == 0:
		source_body.queue_free()
	else:
		#print(Geometry.is_polygon_clockwise(result[0]))
		# Assign the first result to this object
		source_poly.polygon = result[0]
		source_body.get_node("CollisionPoly").set_deferred("polygon", result[0])
		
		# If there are more results, create new objects for them
		for res_poly in result.slice(1,len(result)):
			#print(Geometry.is_polygon_clockwise(res_poly))
			var new_terr = create_new_terrain(res_poly, source_poly.color)
			add_child(new_terr)
	
	# Free the polygon to avoid memory leak
	offset_poly.queue_free()

func create_new_terrain(polygon : PoolVector2Array, poly_color):
	var newTerrain = destructible.instance()
	newTerrain.get_node("RenderPoly").polygon = polygon
	newTerrain.get_node("CollisionPoly").polygon = polygon
	newTerrain.get_node("RenderPoly").color = poly_color
	return newTerrain

# Size of the chunks in pixels
const CHUNK_SIZE := 64
# Partition terrain into chunks
func chunkify_terrain() -> void:
	
	# Array for newly created chunks
	# (they'll be added as children at the end of this function,
	# after the loop terminates)
	var chunk_array = []
	
	for terrain_obj in get_children():
		# Skip items that have been hidden in the editor
		if not terrain_obj.visible: continue
		
		var terr_poly = terrain_obj.polygon
		
		# Get extents (manually D,:)
		var extents = [Vector2.ZERO, Vector2.ZERO]
		for point in terr_poly:
			if point.x < extents[0].x: extents[0].x = point.x
			if point.y < extents[0].y: extents[0].y = point.y
			if point.x > extents[1].x: extents[1].x = point.x
			if point.y > extents[1].y: extents[1].y = point.y
		
		for x in range(extents[0].x, extents[1].x, CHUNK_SIZE):
			for y in range(extents[0].y, extents[1].y, CHUNK_SIZE):
				# Create the chunk polygon, counterclockwise.
				var chunk_poly = PoolVector2Array([
					Vector2(x, y), 
					Vector2(x, y+CHUNK_SIZE), 
					Vector2(x+CHUNK_SIZE, y+CHUNK_SIZE), 
					Vector2(x+CHUNK_SIZE, y), 
					])
				
				# Do intersection of terrain and chunk
				var result = Geometry.intersect_polygons_2d(terr_poly, chunk_poly)
				
				# Create object for each result
				for res_poly in result:
					var new_terr = create_new_terrain(res_poly, terrain_obj.color)
					chunk_array.append(new_terr)
	
	# Remove old collision polys
	for c in get_children():
		c.queue_free()
	
	# Add new chunks
	for chunk in chunk_array:
		add_child(chunk)
