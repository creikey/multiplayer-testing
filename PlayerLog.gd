extends VBoxContainer

export (PackedScene) var player_log_pack

func _ready():
# warning-ignore:return_value_discarded
	Lobby.connect("update_lobby", self, "_on_Lobby_update_lobby")

func _on_Lobby_update_lobby(player_info):
	for child in get_children():
		if child.is_in_group("player_logs"):
			child.queue_free()
	for p in player_info.keys():
		if p == 1: # don't show server info
			continue
		var cur_pack = player_log_pack.instance()
		add_child(cur_pack)
		cur_pack.get_node("Label").text = player_info[p]["user_name"]
		cur_pack.get_node("ColorRect").color = player_info[p]["color"]
		cur_pack.name = str(p)