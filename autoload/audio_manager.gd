extends Node

## AudioManager - サウンド再生管理システム
##
## 責務:
## - サウンドエフェクトの再生
## - AudioStreamPlayerのプーリング
## - 音量管理

const MAX_AUDIO_PLAYERS: int = 16  # 同時再生可能数

## サウンドエフェクトパス（存在しない場合は再生スキップ）
const SOUND_PATHS = {
	"shoot": "res://assets/sounds/shoot.ogg",
	"hit": "res://assets/sounds/hit.ogg",
	"explosion": "res://assets/sounds/explosion.ogg",
	"levelup": "res://assets/sounds/levelup.ogg",
	"pickup": "res://assets/sounds/pickup.ogg",
	"ui_click": "res://assets/sounds/ui_click.ogg"
}

## プリロードされたサウンド（存在するもののみ）
var _sounds: Dictionary = {}

## 利用可能なAudioStreamPlayerプール
var _audio_players: Array[AudioStreamPlayer] = []
var _active_players: Array[AudioStreamPlayer] = []

## 音量設定（0.0-1.0）
var master_volume: float = 0.7
var sfx_volume: float = 0.8


func _ready() -> void:
	# AudioStreamPlayerプールを初期化
	for i in range(MAX_AUDIO_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		player.finished.connect(_on_player_finished.bind(player))
		_audio_players.append(player)

	# サウンドをプリロード（存在するもののみ）
	_load_sounds()


## サウンドファイルをロード
func _load_sounds() -> void:
	var files_found = 0
	for sound_name in SOUND_PATHS:
		var path = SOUND_PATHS[sound_name]
		if ResourceLoader.exists(path):
			var audio_stream = load(path)
			if audio_stream != null:
				_sounds[sound_name] = audio_stream
				DebugConfig.log_debug("AudioManager", "Loaded sound: %s" % sound_name)
				files_found += 1
		else:
			DebugConfig.log_info("AudioManager", "Sound file not found (skipped): %s" % path)

	# サウンドファイルが1つも見つからない場合、プレースホルダー生成
	if files_found == 0:
		DebugConfig.log_info("AudioManager", "No sound files found. Generating placeholder beeps.")
		_generate_placeholder_sounds()


## サウンドエフェクトを再生
func play_sfx(sound_name: String, volume_db: float = 0.0) -> void:
	if not _sounds.has(sound_name):
		# サウンドファイルが存在しない場合はスキップ（エラーログなし）
		return

	var player = _get_available_player()
	if player == null:
		DebugConfig.log_debug("AudioManager", "No available audio player for: %s" % sound_name)
		return

	player.stream = _sounds[sound_name]
	player.volume_db = volume_db + linear_to_db(master_volume * sfx_volume)
	player.play()

	_audio_players.erase(player)
	_active_players.append(player)


## 利用可能なプレイヤーを取得
func _get_available_player() -> AudioStreamPlayer:
	if _audio_players.is_empty():
		return null
	return _audio_players[0]


## プレイヤー再生完了時
func _on_player_finished(player: AudioStreamPlayer) -> void:
	_active_players.erase(player)
	_audio_players.append(player)


## マスター音量を設定
func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)


## SFX音量を設定
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)


## プレースホルダーサウンドを生成（シンプルなビープ音）
func _generate_placeholder_sounds() -> void:
	# 各サウンドタイプに異なる周波数のビープ音を割り当て
	_sounds["shoot"] = _create_beep(800.0, 0.1)      # 高音、短い
	_sounds["hit"] = _create_beep(400.0, 0.08)       # 中音、極短
	_sounds["explosion"] = _create_beep(200.0, 0.3)  # 低音、長め
	_sounds["levelup"] = _create_beep(1200.0, 0.5)   # 最高音、長い
	_sounds["pickup"] = _create_beep(1000.0, 0.15)   # 高音、短め
	_sounds["ui_click"] = _create_beep(600.0, 0.05)  # 中高音、最短

	DebugConfig.log_info("AudioManager", "Generated %d placeholder beep sounds" % _sounds.size())


## シンプルなビープ音を生成
func _create_beep(frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate = 22050
	var sample_count = int(sample_rate * duration)

	var samples = PackedVector2Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t = float(i) / sample_rate
		# サイン波生成
		var value = sin(t * frequency * TAU)

		# エンベロープ（フェードアウト）
		var envelope = 1.0 - (float(i) / sample_count)
		value *= envelope * 0.3  # 音量を30%に制限

		samples[i] = Vector2(value, value)  # ステレオ

	var stream = AudioStreamWAV.new()
	stream.data = _pack_samples(samples)
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = true

	return stream


## PackedVector2Array を PackedByteArray に変換
func _pack_samples(samples: PackedVector2Array) -> PackedByteArray:
	var bytes = PackedByteArray()
	bytes.resize(samples.size() * 4)  # 2チャンネル × 2バイト

	for i in range(samples.size()):
		var left = int(clamp(samples[i].x * 32767.0, -32768.0, 32767.0))
		var right = int(clamp(samples[i].y * 32767.0, -32768.0, 32767.0))

		# Little endian 16-bit
		bytes[i * 4 + 0] = left & 0xFF
		bytes[i * 4 + 1] = (left >> 8) & 0xFF
		bytes[i * 4 + 2] = right & 0xFF
		bytes[i * 4 + 3] = (right >> 8) & 0xFF

	return bytes
