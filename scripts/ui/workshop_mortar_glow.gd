extends ColorRect
## A soft halo drawn behind the mortar, using its painted alpha silhouette.
const GlowShader := preload("res://scripts/ui/workshop_mortar_glow.gdshader")
const DURATION := 2.2
const PADDING := 28.0
const MASK_PADDING := 112
static var cached_masks: Dictionary = {}
var active := false
var calm := false
var elapsed := 0.0:
	set(value):
		elapsed = value
		if glow_material != null:
			var envelope := smoothstep(0,0.16,elapsed)*(1-smoothstep(DURATION-0.24,DURATION,elapsed))
			glow_material.set_shader_parameter("intensity",envelope*0.95)
			glow_material.set_shader_parameter("elapsed",elapsed)
var animation: Tween
var glow_material: ShaderMaterial


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	show_behind_parent = true
	color = Color.WHITE
	glow_material = ShaderMaterial.new()
	glow_material.shader = GlowShader
	material = glow_material
	hide()


func bind_atlas(atlas: Texture2D, region: Rect2) -> void:
	var key := "%s:%s" % [atlas.get_instance_id(),region]
	var mask_size := Vector2i(region.size)+Vector2i.ONE*MASK_PADDING*2
	if not cached_masks.has(key):
		var source := atlas.get_image().get_region(Rect2i(region))
		var mask := Image.create(mask_size.x,mask_size.y,false,Image.FORMAT_RGBA8)
		mask.fill(Color.TRANSPARENT)
		mask.blit_rect(source,Rect2i(Vector2i.ZERO,source.get_size()),Vector2i.ONE*MASK_PADDING)
		mask.generate_mipmaps()
		cached_masks[key] = ImageTexture.create_from_image(mask)
	var texture_size := Vector2(mask_size)
	glow_material.set_shader_parameter("painted_mask",cached_masks[key])
	glow_material.set_shader_parameter("source_size",region.size)
	glow_material.set_shader_parameter("mask_region",Vector4(MASK_PADDING/texture_size.x,MASK_PADDING/texture_size.y,region.size.x/texture_size.x,region.size.y/texture_size.y))


func set_bowl_rect(rect: Rect2) -> void:
	position = rect.position-Vector2.ONE*PADDING
	size = rect.size+Vector2.ONE*PADDING*2
	glow_material.set_shader_parameter("bowl_size",rect.size)
	glow_material.set_shader_parameter("quad_size",size)
	glow_material.set_shader_parameter("quad_origin",position)
	glow_material.set_shader_parameter("visible_size",get_parent().size)


func play(reduced_motion: bool) -> void:
	reset()
	calm = reduced_motion
	glow_material.set_shader_parameter("calm",calm)
	active = true
	show()
	animation = create_tween()
	animation.tween_property(self,"elapsed",DURATION,DURATION)
	animation.tween_callback(reset)


func reset() -> void:
	if animation != null: animation.kill()
	active = false
	elapsed = 0
	hide()
