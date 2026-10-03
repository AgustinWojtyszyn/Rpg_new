class_name GeneratedArt
extends RefCounted

static func direction_key(direction: Vector2) -> StringName:
	var value := direction.normalized()
	if value == Vector2.ZERO:
		return &"south"

	if absf(value.x) < 0.38:
		return &"south" if value.y >= 0.0 else &"north"
	if absf(value.y) < 0.38:
		return &"east" if value.x >= 0.0 else &"west"

	if value.x >= 0.0 and value.y >= 0.0:
		return &"south-east"
	if value.x < 0.0 and value.y >= 0.0:
		return &"south-west"
	if value.x >= 0.0 and value.y < 0.0:
		return &"north-east"
	return &"north-west"

static func texture_for(base_path: String, direction: Vector2) -> Texture2D:
	var key := String(direction_key(direction))
	var directional_path := "%s_%s.png" % [base_path, key]
	if ResourceLoader.exists(directional_path):
		return load(directional_path) as Texture2D

	var fallback_path := "%s.png" % base_path
	if ResourceLoader.exists(fallback_path):
		return load(fallback_path) as Texture2D
	return null

static func make_sprite(base_path: String, scale_factor: float = 1.0, layer: int = 8) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture_for(base_path, Vector2.DOWN)
	sprite.scale = Vector2.ONE * scale_factor
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.z_index = layer
	sprite.set_meta("generated_art_direction", &"south")
	return sprite

static func update_direction(sprite: Sprite2D, base_path: String, direction: Vector2) -> void:
	if not is_instance_valid(sprite) or direction == Vector2.ZERO:
		return
	var key := direction_key(direction)
	if StringName(sprite.get_meta("generated_art_direction", &"")) == key:
		return
	var texture := texture_for(base_path, direction)
	if texture != null:
		sprite.texture = texture
		sprite.set_meta("generated_art_direction", key)
