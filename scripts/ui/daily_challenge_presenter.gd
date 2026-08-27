class_name DailyChallengePresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var weather_label: Label
var title_label: Label
var body_label: Label
var status_label: Label
var action_button: Button
var claim_button: Button


func bind(
	weather: Label,
	title: Label,
	body: Label,
	status: Label,
	action: Button,
	claim: Button
) -> void:
	weather_label = weather
	title_label = title
	body_label = body
	status_label = status
	action_button = action
	claim_button = claim


func is_bound() -> bool:
	return weather_label != null and title_label != null and body_label != null and status_label != null and action_button != null and claim_button != null


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	weather_label.text = game_session.get_daily_challenge_weather_summary()
	title_label.text = game_session.get_daily_challenge_title().to_upper()
	body_label.text = game_session.get_daily_challenge_body()
	status_label.text = game_session.get_daily_challenge_status().to_upper()
	var target_available := game_session.get_daily_challenge_target_slot() >= 0
	action_button.disabled = game_session.daily_challenge_completed or game_session.daily_challenge_claimed or not target_available
	action_button.text = "ÚKOL SPLNĚN" if game_session.daily_challenge_completed or game_session.daily_challenge_claimed else (game_session.get_daily_challenge_action_label() if target_available else "ČEKÁ NA VHODNÝ STAV")
	if not bool(action_button.get_meta("phase161_uses_baked_painted_surface", false)):
		ComicUITheme.apply_button(action_button, ComicUITheme.BLUE if not action_button.disabled else Color("#74848b"), ComicUITheme.CREAM, 14)
	claim_button.disabled = not game_session.daily_challenge_completed or game_session.daily_challenge_claimed
	var pack_reward_text := "1 BALÍČEK"
	if game_session.has_method("get_botanical_pack_state") and bool(game_session.get_botanical_pack_state().get("queue_full", false)):
		pack_reward_text = "ZÁSOBNÍK BALÍČKŮ JE PLNÝ"
	claim_button.text = "ODMĚNA VYZVEDNUTA" if game_session.daily_challenge_claimed else ("VYZVEDNOUT ODMĚNU\n12 MINCÍ · 10 XP · %s" % pack_reward_text if game_session.daily_challenge_completed else "NEJDŘÍV SPLŇ DNEŠNÍ ÚKOL")
	if not bool(claim_button.get_meta("phase161_uses_baked_painted_surface", false)):
		ComicUITheme.apply_button(claim_button, ComicUITheme.GREEN if not claim_button.disabled else Color("#74848b"), ComicUITheme.INK if not claim_button.disabled else ComicUITheme.CREAM, 14)
