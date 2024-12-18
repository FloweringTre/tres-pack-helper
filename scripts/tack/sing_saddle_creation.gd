extends Control

var artist : bool = false
var set_name : bool = false
var set_coin : bool = false

var sad_western : bool = true
var sad_english : bool = false
var adventure : bool = false

var text_icon : bool = false
var text_render : bool = false
var text_rack : bool = false

var image_icon : Image
var image_render : Image
var image_rack : Image
var icon_save_path : String
var render_save_path : String
var rack_save_path : String
var icon_source : String
var render_source : String
var rack_source : String

var coin : String

var file_name : String
var path : String
var file_opened : String

signal new_tack_saved

func _ready() -> void:
	ErrorManager.error_alert.connect(on_error)
	$errorMessage.error_continue.connect(on_error_continue)
	new_tack_saved.connect(on_new_tack_saved)
	$popUP_Saved.deny.connect(on_popup_saved_back)
	$popUP_Saved.confirm.connect(on_popup_saved_confirmed)
	$popUP2_Dupe.deny.connect(on_popup_dupe_back)
	$popUP2_Dupe.confirm.connect(on_popup_dupe_confirmed)
	$popUPexit.deny.connect(on_popup_exit_denied)
	$popUPexit.confirm.connect(on_popup_exit_confirmed)
	$helpscreen.visible = true
	$FileDialog.current_dir = GlobalScripts.directory_root
	starting_coin_values()
	update_name_previews()
	if GlobalScripts.artist != "":
		%artistText.text = GlobalScripts.artist
		artist = true
		ready_to_save()

func on_error() -> void:
	$popUPload.stop_loading()
	disable_interaction()

func on_error_continue() -> void:
	enable_interaction()

func _on_back_button_pressed() -> void:
	if %artistText.text != "" or %inspoText.text != "" or %tackText.text != "" or text_icon or text_render or text_rack:
		are_you_sure()
	else:
		get_tree().change_scene_to_file("res://scene/tackMenuGUI.tscn")

func disable_interaction() -> void:
	%confirmButton.disabled = true
	%backButton.disabled = true
	%artistText.editable = false
	%inspoText.editable = false
	%tackText.editable = false
	%armorCheckBox.disabled = true
	%coinOptions.disabled = true
	%SaddleCheckButton.disabled = true
	%saddleSpinBox.editable = false
	%iconButton.set_disabled()
	%renderButton.set_disabled()
	%rackButton.set_disabled()

func enable_interaction() -> void:
	%confirmButton.disabled = false
	%backButton.disabled = false
	%artistText.editable = true
	%inspoText.editable = true
	%tackText.editable = true
	%armorCheckBox.disabled = false
	%coinOptions.disabled = false
	%SaddleCheckButton.disabled = false
	%saddleSpinBox.editable = true
	%iconButton.reenable_button()
	%renderButton.reenable_button()
	%rackButton.reenable_button()

################### VALUE LOGGING ######################
func _on_artist_text_text_changed(new_text: String) -> void:
	if %artistText.text != "":
		artist = true
	else:
		artist = false
	ready_to_save()

func _on_tack_text_text_changed(new_text: String) -> void:
	update_name_previews()
	if %tackText.text != "":
		set_name = true
	else:
		set_name = false
	ready_to_save()

func update_name_previews() -> void:
	var text = ""
	if %tackText.text == "":
		text = "Indigo"
	else:
		text = %tackText.text
	%inGameLabel.text = text + " Saddle"
	%dataLabel.text = GlobalScripts.text_clean(text) + "_saddle"

func _on_armor_check_box_pressed() -> void:
	if adventure:
		adventure = false
		%armorLabel.text = "No"
	else:
		adventure = true
		%armorLabel.text = "Yes"

func _on_coin_options_item_selected(index: int) -> void:
	set_coin = true
	ready_to_save()
	match index:
		0:
			coin = "copper"
		1:
			coin = "iron"
		2:
			coin = "emerald"
		3:
			coin = "gold"
		4:
			coin = "diamond"
		5:
			coin = "netherite"
		6:
			coin = "amethyst"

func ready_to_save() -> void:
	if artist && set_name && set_coin:
		%confirmButton.disabled = false
	else:
		%confirmButton.disabled = true

#########################################################
func _on_confirm_button_pressed() -> void:
	if %inspoText.text == "":
		%inspoText.text = "N/a"
	$popUPload.loading("Checking for duplicates")
	disable_interaction()
	if TackScripts.tack_dupe_check("saddle", %tackText.text):
		$popUPload.stop_loading()
		dupe_exists()
	else:
		_save_tack()

func dupe_exists() -> void:
	var title = "This item already exists!"
	var message = "There already exists an item named '" + %tackText.text + " Saddle'. \nWhat do you want to do?"
	var no_label = "Go Back"
	var yes_label = "Overwrite it"
	$popUP2_Dupe.pop_yesNo(title, message, no_label, yes_label)
	disable_interaction()

func _save_tack() -> void:
	$popUPload.loading("Saving Saddle")
	var save_path = GlobalScripts.join_paths(GlobalScripts.textures_root, "tack/saddle")
	if sad_western:
			TackScripts.saddle_save(%tackText.text, %artistText.text, %inspoText.text, coin, "western", adventure, text_icon, text_render, text_rack, %saddleSpinBox.value)
	if sad_english:
			TackScripts.saddle_save(%tackText.text, %artistText.text, %inspoText.text, coin, "english", adventure, text_icon, text_render, text_rack, %saddleSpinBox.value)
	
	if text_icon:
		icon_save_path = save_path + "/" + GlobalScripts.text_clean(%tackText.text) + "_saddle_icon.png"
		image_icon.save_png(icon_save_path)
		GlobalScripts.report("Saved user selected image: " + icon_source + "  to the file location: " + icon_save_path)
	if text_render:
		render_save_path = save_path + "/" + GlobalScripts.text_clean(%tackText.text) + "_saddle_legacy.png"
		image_render.save_png(render_save_path)
		GlobalScripts.report("Saved user selected image: " + render_source + "  to the file location: " + render_save_path)
	if text_rack:
		rack_save_path = save_path + "/rack_horse_armor_" + GlobalScripts.text_clean(%tackText.text) + "_saddle.png"
		image_rack.save_png(rack_save_path)
		GlobalScripts.report("Saved user selected image: " + rack_source + "  to the file location: " + rack_save_path)
	
	if ErrorManager.is_error:
			return
	else:
		$popUPload.stop_loading()
		new_tack_saved.emit()

func on_popup_dupe_back() -> void:
	enable_interaction()

func on_popup_dupe_confirmed() -> void:
	_save_tack()

func on_new_tack_saved() -> void:
	var title = "Complete!"
	var message = "Successfully added '" + %tackText.text + " Saddle' to the pack folder. \nWhat do you want to do now?"
	var no_label = "Return to Menu"
	var yes_label = "Make Another"
	$popUP_Saved.pop_yesNo(title, message, no_label, yes_label)
	disable_interaction()

func on_popup_saved_back() -> void:
	get_tree().change_scene_to_file("res://scene/tackMenuGUI.tscn")

func on_popup_saved_confirmed() -> void:
	enable_interaction()
	get_tree().reload_current_scene()

func are_you_sure() -> void:
	var title = "Wait a moment!"
	var message = "Are you sure you want to return to the Tack Menu?"
	var no_label = "Go Back"
	var yes_label = "Continue to Menu"
	$popUPexit.pop_yesNo(title, message, no_label, yes_label)
	disable_interaction()

func on_popup_exit_denied() -> void:
	enable_interaction()

func on_popup_exit_confirmed() -> void:
	get_tree().change_scene_to_file("res://scene/tackMenuGUI.tscn")

###########################################################

func _on_saddle_check_button_pressed() -> void:
	if sad_western:
		sad_western = false
		sad_english = true
		%WestSadLabel.add_theme_color_override("font_color", Color(0.49, 0.36, 0.22))
		%EngSadLabel.add_theme_color_override("font_color", Color(0.306, 0.271, 0.133))
	else:
		sad_western = true
		sad_english = false
		%WestSadLabel.add_theme_color_override("font_color", Color(0.306, 0.271, 0.133))
		%EngSadLabel.add_theme_color_override("font_color", Color(0.49, 0.36, 0.22))

func starting_coin_values() -> void:
	%saddleSpinBox.value = TackScripts.cost_saddle

func _on_file_dialog_file_selected(path: String) -> void:
	var target_line : LineEdit
	if file_opened == "icon":
		target_line = %iconLineEdit
		text_icon = true
		icon_source = path
		image_icon = Image.load_from_file(path)
		%iconButton.button_label.text = "Icon"
	
	if file_opened == "render":
		target_line = %renderLineEdit
		text_render = true
		render_source = path
		image_render = Image.load_from_file(path)
		%renderButton.button_label.text = "Tack"
	
	if file_opened == "rack":
		target_line = %rackLineEdit
		text_rack = true
		rack_source = path
		image_rack = Image.load_from_file(path)
		%rackButton.button_label.text = "Rack"

	var image_file_name = path.split("/")
	image_file_name = image_file_name[-1]
	target_line.text = " " + image_file_name

func _on_icon_button_button_pressed() -> void:
	file_opened = "icon"
	$FileDialog.visible = true
	$FileDialog.title = "Select the Icon Texture"

func _on_render_button_button_pressed() -> void:
	file_opened = "render"
	$FileDialog.visible = true
	$FileDialog.title = "Select the Tack Texture"

func _on_rack_button_button_pressed() -> void:
	file_opened = "rack"
	$FileDialog.visible = true
	$FileDialog.title = "Select the Saddle Rack Texture"
