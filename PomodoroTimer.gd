###########################################################
#  Pomodoro type work timer to help improve work schedule
#  
###########################################################
#  GPL License V3. Use / Edit and return to the community
#  
###########################################################

extends Control

##########################################
# You must select the PomodoroTimer node 
# and assign the two Script Variables there 
# to the two dropdown nodes before this script will work
export (NodePath) var dropdownWork_path
export (NodePath) var dropdownBreak_path
##########################################
onready var dropdownWorkSounds = get_node(dropdownWork_path)
onready var dropdownBreakSounds = get_node(dropdownBreak_path)
onready var SoundPlayer = get_node("AudioStreamPlayer")
onready var t = get_node("Timer")
onready var progressMeter = get_node("ProgressBar")
onready var l = get_node("LabelHint")

#3 x included sound files are in root of project
var sound_array 	= ["Gong", "Soothe", "Alarm"]
var sample_library 	= {"0": preload("res://gong.wav"), "1": preload("res://soothe.wav"), "2": preload("res://alarm.wav")}
var playSounds 		= true
var soundWorkEnd	= "0"
var soundBreakEnd	= "0"

# defaults based on my likings.  No ability to save on each run yet
var timeShortBreak 	= 300 #5 x 60 seconds
var timeLongBreak 	= 600 #10 x 60 seconds
var timeWorkPeriod	= 1500 #25 x 60 seconds
var state = "stopped"  #stopped, working, break
var lastState = state

func _ready():
	add_sound_items()
	
func _process(delta):
	#debug output
	get_node("debugLabel-Timer").text = str(round(t.time_left))
	
	#work out how much of the timer has progressed for the progressbar to update
	progressMeter.value = t.time_left


func setProgressBarLimits(value):
	progressMeter.max_value = value
	print("progress max is: ", str(value))


#fill up the dropdown menus
func add_sound_items():
	for item in sound_array:
		dropdownWorkSounds.add_item(item)
		dropdownBreakSounds.add_item(item)

func play_sample(var sound):
	print("playing sound :", str(sound))
	if playSounds:
	    if sample_library.has(sound):
	        SoundPlayer.stream = sample_library[sound]
	        SoundPlayer.play()

func _on_DropDownWorkEnd_item_selected( ID ):
	#play the sound so they can hear it as a test
	play_sample(str(ID))
	#assign it as the sound to use
	soundWorkEnd = str(ID)
	

func _on_DropDownBreakEnd_item_selected( ID ):
	#play the sound so they can hear it as a test
	play_sample(str(ID))
	#assign it as the sound to use
	soundBreakEnd = str(ID)


func _on_CheckButtonSound_pressed():
	if playSounds:
		playSounds = false
	else:
		playSounds = true

func changeTextValue( labelName, value):
	var textValue
	if value == 1:
		textValue = str(value) + " minute"
	else:
		textValue = str(value) + " minutes"	
	get_node(labelName).set_text(textValue)

func _on_HSliderWork_value_changed( value ):
	changeTextValue("Panel/VBoxContainer/HBoxContainer/LabelWorkMinutes", value)
	timeWorkPeriod = value*60

func _on_HSliderBreakShort_value_changed( value ):
	changeTextValue("Panel/VBoxContainer/HBoxContainer2/LabelBreakShortMinutes", value)
	timeShortBreak = value*60

func _on_HSliderBreakLong_value_changed( value ):
	changeTextValue("Panel/VBoxContainer/HBoxContainer3/LabelBreakLongMinutes", value)
	timeLongBreak = value*60

func _on_ButtonWork_pressed():
	#whilst we're here, update the progress bar's max value
	setProgressBarLimits(timeWorkPeriod)
	t.wait_time = timeWorkPeriod
	t.start()
	lastState = state
	state = "working"
	l.text = "I'm focused and working"
	changeButtonStatus()
	changeHintStatus()


func _on_ButtonBreakShort_pressed():
	#whilst we're here, update the progress bar's max value
	setProgressBarLimits(timeShortBreak)
	t.wait_time = timeShortBreak
	t.start()
	lastState = state
	state = "break"
	l.text = "On a short break"
	changeButtonStatus()
	changeHintStatus()


func _on_ButtonBreakLong_pressed():
	#whilst we're here, update the progress bar's max value
	setProgressBarLimits(timeLongBreak)
	t.wait_time = timeLongBreak
	t.start()
	lastState = state
	state = "break"
	l.text = "On a longer break"
	changeButtonStatus()
	changeHintStatus()

func _on_Timer_timeout():
	if state == "working":
		play_sample(soundWorkEnd)
		lastState = state
		state = "stopped"
	elif state == "break":
		play_sample(soundBreakEnd)
		lastState = state
		state = "stopped"
	changeButtonStatus()
	changeHintStatus()
	OS.request_attention()
	
	
func changeButtonStatus():
	if state == "stopped":
		get_node("ButtonWork").text = "Start Work"
		get_node("ButtonBreakLong").text = "Start Long Break"
		get_node("ButtonBreakShort").text = "Start Short Break"
	elif state == "break":
		get_node("ButtonWork").text = "Start Work"
		get_node("ButtonBreakLong").text = "Taking a Break"
		get_node("ButtonBreakShort").text = "Taking a Break"
	elif state == "working":
		get_node("ButtonWork").text = "Currently Working"
		get_node("ButtonBreakLong").text = "Start Long Break"
		get_node("ButtonBreakShort").text = "Start Short Break"
	
	
func changeHintStatus():
	if lastState == "working":
		l.text = "Work finished. Time for a break."
	elif lastState == "break":
		l.text = "Break over.  Time to focus onwork"

