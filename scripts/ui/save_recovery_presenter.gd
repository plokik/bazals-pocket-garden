class_name SaveRecoveryPresenter
extends RefCounted

const INITIAL_BUTTON_TEXT := "ZAČÍT NOVOU HRU"
const CONFIRM_BUTTON_TEXT := "OPRAVDU SMAZAT A ZAČÍT ZNOVU"
const PROTECTION_NOTICE := "Dokud se nerozhodneš, hra starý soubor nepřepíše. Nová hra vyžaduje druhé potvrzení."
const CONFIRM_NOTICE := "Tento krok odstraní nečitelný lokální save. Stiskni potvrzení ještě jednou."
const FAILURE_NOTICE := "Save se nepodařilo bezpečně odstranit. Zůstal chráněný."

var status_label: Label
var confirm_button: Button


func bind(label: Label, button: Button) -> void:
	status_label = label
	confirm_button = button


func is_bound() -> bool:
	return status_label != null and confirm_button != null


func show_initial(load_message: String) -> void:
	if not is_bound():
		return
	confirm_button.text = INITIAL_BUTTON_TEXT
	status_label.text = "%s\n\n%s" % [load_message, PROTECTION_NOTICE]


func show_confirmation() -> void:
	if not is_bound():
		return
	confirm_button.text = CONFIRM_BUTTON_TEXT
	status_label.text = CONFIRM_NOTICE


func show_delete_failure() -> void:
	if not is_bound():
		return
	status_label.text = FAILURE_NOTICE
