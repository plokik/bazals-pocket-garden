extends SceneTree
func _init() -> void:
 call_deferred("bake")
func bake() -> void:
 var atlas := SubViewport.new()
 atlas.size = Vector2i(1448, 1086)
 atlas.transparent_bg = true
 atlas.render_target_update_mode = SubViewport.UPDATE_ALWAYS
 root.add_child(atlas)
 var paint: Texture2D = load("res://assets/ui/greenhouse/butterfly_amber_v1.png")
 var wing_shader: Shader = load("res://tools/art/greenhouse_butterfly_authoring.gdshader")
 for index in range(12):
  var sprite := Sprite2D.new()
  sprite.texture = paint
  sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
  sprite.position = Vector2((index % 4) * 362 + 181, (index / 4) * 362 + 181)
  sprite.scale = Vector2.ONE * 320.0 / paint.get_width()
  var material := ShaderMaterial.new()
  material.shader = wing_shader
  var phase := index * TAU / 12.0
  material.set_shader_parameter("left_wing_open", 0.58 + 0.42 * (0.5 + 0.5 * cos(phase)))
  material.set_shader_parameter("right_wing_open", 0.58 + 0.42 * (0.5 + 0.5 * cos(phase + 0.16)))
  material.set_shader_parameter("flap_phase", phase)
  sprite.material = material
  atlas.add_child(sprite)
 await process_frame
 await RenderingServer.frame_post_draw
 var result := atlas.get_texture().get_image()
 var error := result.save_png("res://assets/ui/greenhouse/butterfly_flight_v2.png")
 if error != OK:
  push_error("Atlas save failed")
  quit(2)
  return
 print("BUTTERFLY_ATLAS_BAKE=PASSED; SIZE=1448x1086; GRID=4x3; PHASES=12")
 quit()
