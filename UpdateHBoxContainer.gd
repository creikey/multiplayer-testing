extends HBoxContainer

func _on_UpdateButton_pressed():
	Lobby.my_info["user_name"] = $NewUsername.text
	Lobby.my_info["color"] = $Panel/HBoxContainer/ColorPickerButton.color
	Lobby.rpc("register_player", get_tree().get_network_unique_id(), Lobby.my_info)
	Lobby.emit_signal("update_lobby", Lobby.player_info, Lobby.my_info)
