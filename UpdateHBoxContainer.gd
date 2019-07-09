extends HBoxContainer

func _on_UpdateButton_pressed():
	Lobby.my_info["user_name"] = $NewUsername.text
	Lobby.my_info["color"] = $Panel/HBoxContainer/ColorPickerButton.color
	Lobby.rpc("update_player_info", get_tree().get_network_unique_id(), Lobby.my_info)