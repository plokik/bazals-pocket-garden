extends Control
## Presentation only. The inventory transaction finishes before this animation.
signal finished
const Atlas := preload("res://assets/ui/workshop/mint_crafting_atlas_v1.png")
const RosemaryAtlas := preload("res://assets/ui/workshop/rosemary_crafting_atlas_v1.png")
const ROSEMARY := Rect2(170,44,620,800)
const BOTTLE := Rect2(1100,60,555,780)
const MORTAR := Rect2(60,115,610,515)
const PESTLE := Rect2(818,44,248,580)
const MINT := Rect2(65,725,600,400)
const POUCH := Rect2(690,677,540,512)
const FontBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const SuccessEffect := preload("res://scripts/ui/workshop_success_effect.gd")
const MortarGlow := preload("res://scripts/ui/workshop_mortar_glow.gd")
var phase := -1.0:
	set(value):
		phase = value
		_layout_mortar_glow()
		queue_redraw()
var tween: Tween
var rosemary := false
var result_caption := "+2"
var success_effect: Control
var mortar_glow: Control

static func mint_icon() -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = Atlas
	texture.region = MINT
	return texture

static func rosemary_icon() -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = RosemaryAtlas
	texture.region = ROSEMARY
	return texture

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_LINEAR
	custom_minimum_size.y = 174
	clip_contents = true
	resized.connect(queue_redraw)
	resized.connect(_layout_mortar_glow)
	mortar_glow = MortarGlow.new()
	add_child(mortar_glow)
	mortar_glow.bind_atlas(Atlas,MORTAR)
	_layout_mortar_glow()
	success_effect = SuccessEffect.new()
	add_child(success_effect)
	success_effect.frame_changed.connect(queue_redraw)

func reset() -> void:
	if tween != null: tween.kill()
	if success_effect != null: success_effect.reset()
	if mortar_glow != null: mortar_glow.reset()
	phase = -1

func play(reduced_motion: bool) -> void:
	reset()
	phase = 2.4 if reduced_motion else 0.0
	mortar_glow.play(reduced_motion)
	tween = create_tween()
	if reduced_motion:
		tween.tween_interval(0.12)
	else:
		tween.tween_property(self,"phase",2.4,2.4)
	tween.tween_callback(func(): success_effect.play(reduced_motion); finished.emit())

func _layout_mortar_glow() -> void:
	if mortar_glow == null: return
	var result := smoothstep(1.8,2.35,phase)
	var center := Vector2(size.x*lerpf(0.5,0.35,result),95)
	mortar_glow.set_bowl_rect(Rect2(center+Vector2(-76,-48),Vector2(152,126)))

func _draw() -> void:
	var result := smoothstep(1.8,2.35,phase)
	var center := Vector2(size.x * lerpf(0.5,0.35,result),95)
	var bowl := Rect2(center + Vector2(-76,-48),Vector2(152,126))
	draw_texture_rect_region(Atlas,bowl,MORTAR)
	var grinding := phase > 0.6 and phase < 1.85
	var tilt := sin((phase - 0.6)*15.0)*0.18 if grinding else 0.18
	var push := sin((phase - 0.6)*15.0)*4.0 if grinding else 0.0
	draw_set_transform(center + Vector2(6,push),tilt)
	draw_texture_rect_region(Atlas,Rect2(-24,-88,48,112),PESTLE)
	draw_set_transform(Vector2.ZERO)
	if phase >= 0 and phase < 0.9:
		for index in range(3):
			var drop := clampf((phase-index*0.13)/0.5,0,1)
			var position := center + Vector2((index-1)*28*(1-drop),-80+64*drop*drop)
			draw_set_transform(position,(index-1)*0.25*drop)
			var herb_rect := Rect2(-13,-21,26,42) if rosemary else Rect2(-19,-14,38,28)
			draw_texture_rect_region(RosemaryAtlas if rosemary else Atlas,herb_rect,ROSEMARY if rosemary else MINT,Color(1,1,1,1-smoothstep(0.75,1.0,drop)))
		draw_set_transform(Vector2.ZERO)
	# Occlude the grinding end behind the painted front lip of the bowl.
	var front := 0.40
	draw_texture_rect_region(Atlas,Rect2(bowl.position + Vector2(0,bowl.size.y*front),Vector2(bowl.size.x,bowl.size.y*(1-front))),Rect2(MORTAR.position+Vector2(0,MORTAR.size.y*front),Vector2(MORTAR.size.x,MORTAR.size.y*(1-front))))
	if result > 0:
		var pouch_center := Vector2(size.x*0.78,91+8*(1-result))
		var result_scale: float = success_effect.result_scale()
		if rosemary:
			draw_texture_rect_region(RosemaryAtlas,Rect2(pouch_center-Vector2(36,51)*result_scale,Vector2(72,102)*result_scale),BOTTLE,Color(1,1,1,result))
			var text_width := FontBold.get_string_size(result_caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x
			draw_string(FontBold,pouch_center+Vector2(-text_width/2,72),result_caption,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color(0.16,0.29,0.16,result))
		else:
			draw_texture_rect_region(Atlas,Rect2(pouch_center-Vector2(43,41)*result_scale,Vector2(86,82)*result_scale),POUCH,Color(1,1,1,result))
			draw_string(FontBold,pouch_center+Vector2(-14,64),"+2",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color(0.16,0.29,0.16,result))
