extends Control

@onready var _name: LineEdit = $Panel/Name
@onready var content: TextEdit = $Panel/Content
@onready var number: SpinBox = $Panel/Number
@onready var color: ColorPickerButton = $Panel/Color
@onready var save_dialog: FileDialog = $GridContainer/Save/Save_dialog
@onready var load_dialog: FileDialog = $GridContainer/Load/Load_dialog
@onready var message: Label = $Message
@onready var message_timer: Timer = $Message_Timer

signal message_send

var Name : String = ""
var Content : String = ""
var Number : float
var color_var : Color
var color_var_store
var data : Dictionary

func _ready() -> void:
	connect("message_send", handle_message)

func handle_message():
	message_timer.start()

func _on_message_timer_timeout() -> void:
	message.text = ""

func _process(delta: float) -> void:
	Name = _name.text
	Content = content.text
	Number = number.value
	color_var = color.color
	color_var_store = color_var.to_html()
	
	data = {
		"Name": Name,
		"Content": Content,
		"Number": Number,
		"Color": color_var_store
	}

func save_data(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))
		file.close()
		message.modulate = Color.AQUAMARINE
		message.text = "Daten gespeichert!"
		emit_signal("message_send")
	else:
		message.modulate = Color.BROWN
		message.text = "Fehler beim Öffnen der Datei zum Schreiben"
		emit_signal("message_send")

func load_data(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		file.close()
		message.modulate = Color.AQUAMARINE
		message.text = "Daten geladen!"
		emit_signal("message_send")
		return data
	else:
		message.modulate = Color.BROWN
		message.text = "Fehler beim Öffnen der Datei zum Lesen"
		emit_signal("message_send")
		return ""

func _on_save_dialog_file_selected(path: String) -> void:
	save_data(path, data)


func _on_load_dialog_file_selected(path: String) -> void:
	data = JSON.parse_string(load_data(path))
	apply_changes(data)


func _on_save_pressed() -> void:
	save_dialog.show()

func _on_load_pressed() -> void:
	load_dialog.show()

func apply_changes(data):
	_name.text = data["Name"]
	content.text = data["Content"]
	number.value = data["Number"]
	color.color = data["Color"] 
