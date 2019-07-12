extends VBoxContainer

export (PackedScene) var player_log_pack

func append_log(player_id, player_info):
#	if player_id == 1: # don't show server info
#			return
	var cur_pack = player_log_pack.instance()
	add_child(cur_pack)
	cur_pack.get_node("Label").text = player_info["user_name"]
	cur_pack.get_node("ColorRect").color = player_info["color"]
	cur_pack.name = str(player_id)

func _ready():
# warning-ignore:return_value_discarded
	Lobby.connect("update_lobby", self, "_on_Lobby_update_lobby")

func _on_Lobby_update_lobby(player_info: Dictionary, my_info):
	for child in get_children():
		if child.is_in_group("player_logs"):
			child.queue_free()
	var all_player_info = player_info.duplicate()
	all_player_info[get_tree().get_network_unique_id()] = my_info
	var key_array = all_player_info.keys()
	key_array.sort()
	for p in key_array:
		append_log(p, all_player_info[p])
