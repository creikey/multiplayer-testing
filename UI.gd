extends CanvasLayer

func hide_network_menu():
	$VBoxContainer/HBoxContainer2.visible = false
	$VBoxContainer/Port.visible = false
	$VBoxContainer/TargetIP.visible = false
	$VBoxContainer/HBoxContainer/JoinServerButton.visible = false
	$VBoxContainer/HBoxContainer/StartServerButton.visible = false

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