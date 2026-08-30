extends RefCounted
## Align the shared ceramic assembly to the painted window sill, not the view bottom.

const Grounding := preload("res://scripts/ui/rack_planter_grounding.gd")
const CONTRACT_ID := "phase172_shared_ceramic_measured_window_sill_v1"
const BACKGROUND_PATH := "res://assets/backgrounds/comic_detail_window_v1.png"
const BG_SIZE := Vector2(887.0, 1024.0)
const SHELF_BACK_Y := 798.0
const SHELF_FRONT_Y := 928.0
const FRONT_CLEARANCE := 11.0


static func shelf_y(area: Vector2) -> float:
	return (SHELF_FRONT_Y - FRONT_CLEARANCE) * area.y / BG_SIZE.y


static func shelf_back_y(area: Vector2) -> float:
	return SHELF_BACK_Y * area.y / BG_SIZE.y


static func layout(texture: Texture2D, area: Vector2) -> Dictionary:
	if texture == null or area.x <= 0.0 or area.y <= 0.0:
		return {}
	var canvas := texture.get_size()
	var image_height := minf(310.0, area.y * 1.02)
	var image_size := Vector2(image_height * canvas.x / maxf(1.0, canvas.y), image_height)
	if image_size.x > area.x * 0.78:
		image_size *= area.x * 0.78 / image_size.x
	var floor_y := shelf_y(area)
	var fitted := Rect2(Vector2((area.x - image_size.x) * 0.5, floor_y - image_size.y), image_size)
	var geometry := Grounding.layout(texture.resource_path, fitted, floor_y)
	if geometry.is_empty():
		return {}
	# The same PNG/seat ratio as the rack. A short viewport must fit both the
	# full sprite canvas AND the entire shallow saucer on the actual top board.
	var plant_rect: Rect2 = geometry.plant_rect
	var saucer_rect: Rect2 = geometry.saucer_rect
	var top_inset := maxf(8.0, area.y * 0.025)
	var fit_scale := minf(1.0, (floor_y - top_inset) / maxf(1.0, floor_y - plant_rect.position.y))
	fit_scale = minf(fit_scale, (floor_y - shelf_back_y(area)) / maxf(1.0, saucer_rect.size.y))
	if fit_scale < 1.0:
		image_size *= maxf(0.0, fit_scale)
		fitted = Rect2(Vector2((area.x - image_size.x) * 0.5, floor_y - image_size.y), image_size)
		geometry = Grounding.layout(texture.resource_path, fitted, floor_y)
	geometry["texture"] = texture
	return geometry
