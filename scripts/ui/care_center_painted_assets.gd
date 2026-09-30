extends RefCounted
## Exact crops of the approved atlas, prepared by tools/bake_painted_ui.gd.
## Startup loads ready textures without a GDScript pixel loop.

const SOURCE := "res://assets/ui/care_center_painted_v1/icon_atlas.png"
const COLUMNS := 4
const ROWS := 3
const ICONS := [
	"sick_leaf", "water_alert", "mint_basket", "drying_tray",
	"empty_pot", "lock", "clock_leaf", "reminder",
	"return_pot", "wind", "watering_can", "harvest_basket",
]

const TEXTURES := {
	"sick_leaf": preload("res://assets/ui/care_center_painted_v1/runtime/sick_leaf.png"),
	"water_alert": preload("res://assets/ui/care_center_painted_v1/runtime/water_alert.png"),
	"mint_basket": preload("res://assets/ui/care_center_painted_v1/runtime/mint_basket.png"),
	"drying_tray": preload("res://assets/ui/care_center_painted_v1/runtime/drying_tray.png"),
	"empty_pot": preload("res://assets/ui/care_center_painted_v1/runtime/empty_pot.png"),
	"lock": preload("res://assets/ui/care_center_painted_v1/runtime/lock.png"),
	"clock_leaf": preload("res://assets/ui/care_center_painted_v1/runtime/clock_leaf.png"),
	"reminder": preload("res://assets/ui/care_center_painted_v1/runtime/reminder.png"),
	"return_pot": preload("res://assets/ui/care_center_painted_v1/runtime/return_pot.png"),
	"wind": preload("res://assets/ui/care_center_painted_v1/runtime/wind.png"),
	"watering_can": preload("res://assets/ui/care_center_painted_v1/runtime/watering_can.png"),
	"harvest_basket": preload("res://assets/ui/care_center_painted_v1/runtime/harvest_basket.png"),
}



static func texture(kind: String) -> Texture2D:
	return TEXTURES.get(kind)
