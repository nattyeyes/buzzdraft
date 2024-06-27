extends Control

const TIMERDEFAULT = 1000

var keysound
var keysound_format
var random_int = 0
var timer_value = 0
var timer_running = false
var pressure = "low"

func _ready():
	timer_value = TIMERDEFAULT
	$PressureTimer/TimerBar.max_value = TIMERDEFAULT

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode != KEY_SHIFT:
			
			if $Customization/KeysoundPicker.selected != 0:
				keysound_process()
				$KeysoundPlayer.set_stream(keysound)
				$KeysoundPlayer.play()
			
			# For pressure timer! Adds time every keypress.
			if timer_running:
				if timer_value >= TIMERDEFAULT:
					pass
				elif TIMERDEFAULT - timer_value < 10:
					timer_value += TIMERDEFAULT - timer_value
				else:
					timer_value += 10

func _process(_delta):
	update_wordcount()
	update_charcount()
	update_timer()
	pressuresound_process()

func update_wordcount():
	var regex = RegEx.new()
	regex.compile("\\S+")
	var result = regex.search_all($TextEdit.text)
	var wordcount_format = "Word Count: %s"
	$Counters/WordCount.text = wordcount_format % String(result.size())

func update_charcount():
	var charcount_format = "Character Count: %s"
	$Counters/CharCount.text = charcount_format % String($TextEdit.text.length())

func update_timer():
	$PressureTimer/TimerBar.value = timer_value
	
	if timer_running:
		match $PressureTimer/TimerDifficulty.selected:
			0:
				timer_value -= 0.35
			1:
				timer_value -= 1
			2:
				timer_value -= 2
			3:
				timer_value -= 3
		
		if timer_value <= 0:
			$PressurePlayer.stop()
			$TextEdit.text = " "
			timer_running = false
			timer_value = TIMERDEFAULT

func keysound_process():
	randomize()
	random_int = 1 + randi() % 3
	
	match $Customization/KeysoundPicker.selected:
		1:
			keysound_format = "res://SFX/Clicks%s.wav"
		2:
			keysound_format = "res://SFX/Boops%s.wav"
		3:
			keysound_format = "res://SFX/Shells%s.wav"
	
	if $Customization/KeysoundPicker.selected != 0:
		keysound = load(keysound_format % String(random_int))

func pressuresound_process():
	if timer_running:
		if timer_value > 500 && timer_value <= 1000 && pressure != "low":
			$PressurePlayer.set_stream(load("res://SFX/Countdown1.ogg"))
			$PressurePlayer.play()
			pressure = "low"
		elif timer_value > 200 && timer_value <= 500 && pressure != "mid":
			$PressurePlayer.set_stream(load("res://SFX/Countdown2.ogg"))
			$PressurePlayer.play()
			pressure = "mid"
		elif timer_value > 0 && timer_value <= 200 && pressure != "high":
			$PressurePlayer.set_stream(load("res://SFX/Countdown3.ogg"))
			$PressurePlayer.play()
			pressure = "high"

func _on_OpenFile_pressed():
	$OpenDialog.popup()

func _on_SaveFile_pressed():
	$SaveDialog.popup()

func _on_OpenDialog_file_selected(path):
	print(path)
	var f = File.new()
	f.open(path, 1)
	$TextEdit.text = f.get_as_text()

func _on_SaveDialog_file_selected(path):
	var f = File.new()
	f.open(path, 2)
	f.store_string($TextEdit.text)


func _on_FontPicker_item_selected(index):
	match index:
		0:
			$".".get_theme().default_font = load("res://Themes/Fonts/FontNunito.tres")
		1:
			$".".get_theme().default_font = load("res://Themes/Fonts/FontTurpis.tres")
		2:
			$".".get_theme().default_font = load("res://Themes/Fonts/FontSteepedTea.tres")

func _on_TimerStart_pressed():
	timer_running = true
	$PressurePlayer._set_playing(true)

func _on_TimerPause_pressed():
	timer_running = false
	$PressurePlayer.stop()

func _on_TimerReset_pressed():
	timer_running = false
	timer_value = TIMERDEFAULT
	$PressurePlayer.stop()


func _on_TimerVolume_pressed():
	if $PressureTimer/TimerVolume.icon == load("res://Themes/Images/speaker-off.png"):
		$PressureTimer/TimerVolume.icon = load("res://Themes/Images/speaker.png")
		$PressurePlayer.volume_db = -100
	elif $PressureTimer/TimerVolume.icon == load("res://Themes/Images/speaker.png"):
		$PressureTimer/TimerVolume.icon = load("res://Themes/Images/speaker-off.png")
		$PressurePlayer.volume_db = -20


func _on_FullscreenButton_toggled(_button_pressed):
	OS.window_fullscreen = !OS.window_fullscreen


func _on_CreditsButton_pressed():
	$CreditsDialog.popup()


func _on_ThemePicker_item_selected(index):
	match index:
		0:
			$".".set_theme(load("res://Themes/Espresso.tres"))
		1:
			$".".set_theme(load("res://Themes/Skateboard.tres"))
