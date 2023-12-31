extends Node

signal game_over_signal
signal game_started_signal

var restart_v: bool = false
var coin_count: int = 0 # in 1 run
var wallet: int = 0 # long run
var distance: float = 0
var longest_distance: float = 0
var hero: CharacterBody2D
var purchased_items = []

func _ready():
	Global.play_sound(preload("res://sound/Theme.wav"))
	if FileAccess.file_exists("user://save.json"):
		load_game()

func purchase_item(index):
	purchased_items.append(index)

func play_sound(stream: AudioStream, from_position: float = 0.0, volume_db: float = 0.0, pitch: float = 1.0, bus: String = "Master", pause_on_pause: bool = false):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.bus = bus
	player.process_mode = Node.PROCESS_MODE_INHERIT if pause_on_pause else Node.PROCESS_MODE_ALWAYS
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
	return player
	

func reset_data():
	Global.wallet = 0
	Global.longest_distance = 0
	Global.distance = 0
	Global.coin_count = 0
	Global.purchased_items = []
	var file = DirAccess.open("user://")
	file.remove("save.json")

func load_game():
	var string = FileAccess.get_file_as_string("user://save.json")
	var data = JSON.parse_string(string)
	wallet = data["coins"]
	longest_distance = data["distance"]
	if data.has("items"):
		print("ucitanos")
		purchased_items = data["items"]

func save_game():
	var file = FileAccess.open("user://save.json",FileAccess.WRITE)
	var json = JSON.stringify({"coins":wallet,"distance":longest_distance,"items":purchased_items})
	file.store_string(json)
	file.close()


const death_sounds = [
	preload("res://sound/VOICE/death 1-01.wav"),
	preload("res://sound/VOICE/death 1.wav"),
	preload("res://sound/VOICE/death NOVO.wav")
]

func death():
	play_sound(death_sounds[randi()%death_sounds.size()],0.0,-4.0)
	game_over_signal.emit()
	var gameover = preload("res://ui/gameover.tscn").instantiate()
	get_tree().root.add_child(gameover)
	end_game()
	

func end_game():
	longest_distance = max(longest_distance,distance)
	wallet += coin_count
	save_game()
	get_tree().paused = true

func restart():
	coin_count = 0
	get_tree().reload_current_scene()
