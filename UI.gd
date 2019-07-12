extends CanvasLayer

const SAVE_SETTINGS_TIME = 1.0

var cur_settings_save_time = 0.0

func _ready():
	load_settings()

func _process(delta):
	cur_settings_save_time += delta
	if cur_settings_save_time >= SAVE_SETTINGS_TIME:
		save_settings()
		cur_settings_save_time = 0.0

func hide_network_menu():
	$VBoxContainer/HBoxContainer2.visible = false
	$VBoxContainer/Port.visible = false
	$VBoxContainer/TargetIP.visible = false
	$VBoxContainer/HBoxContainer/JoinServerButton.visible = false
	$VBoxContainer/HBoxContainer/StartServerButton.visible = false
	$VBoxContainer/UPNPButton.visible = false

func _on_JoinServerButton_pressed():
	hide_network_menu()
	
	Lobby.my_info["user_name"] = $VBoxContainer/HBoxContainer2/Username.text
	Lobby.my_info["color"] = $VBoxContainer/HBoxContainer2/Panel/HBoxContainer/ColorPickerButton.color
	$VBoxContainer/UpdateHBoxContainer/NewUsername.text = Lobby.my_info["user_name"]
	$VBoxContainer/UpdateHBoxContainer/Panel/HBoxContainer/ColorPickerButton.color = Lobby.my_info["color"]
	$VBoxContainer/UpdateHBoxContainer.visible = true
	Lobby.join_server(int($VBoxContainer/Port.text), $VBoxContainer/TargetIP.text)

func _on_StartServerButton_pressed():
	hide_network_menu()
	$VBoxContainer/HBoxContainer/StartGameButton.visible = true
	Lobby.start_server(int($VBoxContainer/Port.text))

func _on_UPNPButton_pressed():
	if Lobby.upnp != null:
		return
	var port = int($VBoxContainer/Port.text)
	Lobby.upnp = UPNP.new()
	Lobby.forwarded_port = port
	print(Lobby.upnp.discover(2000, 2, "InternetGatewayDevice"))
	print(Lobby.upnp.add_port_mapping(port))

func save_settings():
	var settings_dict = {
		"username": $VBoxContainer/HBoxContainer2/Username.text,
		"color": $VBoxContainer/HBoxContainer2/Panel/HBoxContainer/ColorPickerButton.color,
		"port": $VBoxContainer/Port.text,
		"target_ip": $VBoxContainer/TargetIP.text
	}
	var json_settings = to_json(settings_dict)
	var settings_file: File = File.new()
# warning-ignore:return_value_discarded
	settings_file.open("user://settings.json", File.WRITE)
	settings_file.store_string(json_settings)
	settings_file.close()

func load_settings():
	var settings_file: File = File.new()
	var dir = Directory.new()
	if not dir.file_exists("user://settings.json"): # if file doesn't exist return
		return
# warning-ignore:return_value_discarded
	settings_file.open("user://settings.json", File.READ)
	var settings_dict = parse_json(settings_file.get_as_text())
	if typeof(settings_dict) == TYPE_DICTIONARY:
		$VBoxContainer/HBoxContainer2/Username.text = settings_dict["username"]
		var color_array = settings_dict["color"].split(",")
		var resultant_color = Color()
		resultant_color.r = float(color_array[0])
		resultant_color.g = float(color_array[1])
		resultant_color.b = float(color_array[2])
		resultant_color.a = float(color_array[3])
		$VBoxContainer/HBoxContainer2/Panel/HBoxContainer/ColorPickerButton.color = resultant_color
		$VBoxContainer/Port.text = settings_dict["port"]
		$VBoxContainer/TargetIP.text = settings_dict["target_ip"]
	else:
		printerr("Wrong type from loaded settings file. Expected dict, type is: ", typeof(settings_dict))
		dir.remove("user://settings.json")
	settings_file.close()


func _on_UI_tree_exiting():
	save_settings()
