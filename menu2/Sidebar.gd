extends Panel

var open:bool = false
var open_amt:float = 1

onready var pages:Array = [
	get_node("../Main/Results"),
	get_node("../Main/MapRegistry"),
	get_node("../Main/Settings"),
	get_node("../Main/Credits")
]
onready var buttons:Array = [
	$L/Results,
	$L/MapSelect,
	$L/Settings,
	$L/Credits
]
var use_ver_b:Array = [
	false,
	false,
	true,
	false
]

func press(bi:int,q:bool=false):
	if !q: get_node("../Press").play()
	for i in range(pages.size()):
		pages[i].visible = i == bi
		buttons[i].pressed = i == bi
	yield(get_tree(),"idle_frame")
	open = false
	get_node("../VersionNumber").visible = !use_ver_b[bi]
	get_node("../VersionNumberB").visible = use_ver_b[bi]
	get_node("Click").visible = !open
	get_node("../SidebarClick").visible = open

func to_old_menu():
	get_node("../Press").play()
	get_node("/root/Menu").black_fade_target = true
	yield(get_tree().create_timer(1),"timeout")
	SSP.menu_target = "res://menu.tscn"
	get_tree().change_scene("res://menuload.tscn")

func to_content_mgr():
	get_node("../Press").play()
	get_node("/root/Menu").black_fade_target = true
	yield(get_tree().create_timer(1),"timeout")
	SSP.conmgr_transit = "addsongs"
	get_tree().change_scene("res://contentmgrload.tscn")

func quit():
	get_node("../Press").play()
#	get_node("/root/Menu").black_fade_target = true
#	yield(get_tree().create_timer(1),"timeout")
	get_tree().quit()
	

func _ready():
	for i in range(buttons.size()):
		buttons[i].connect("pressed",self,"press",[i])
	
	if SSP.just_ended_song: press(0,true)
	else: press(1,true)
	
	$L/OldMenu.connect("pressed",self,"to_old_menu")
	$L/ContentMgr.connect("pressed",self,"to_content_mgr")
	$L/Quit.connect("pressed",self,"quit")
	$L/Quit.visible = OS.has_feature("pc")
	

func _process(delta:float):
	if open == true and open_amt != 1:
		open_amt = min(open_amt + max((1 - open_amt) * delta * 14, 0.05*delta),1)
#		if open_amt > 0.99: open_amt = 1
	elif open == false and open_amt != 0:
		open_amt = max(open_amt + min((0 - open_amt) * delta * 12, -0.05*delta),0)
#		if open_amt < 0.01: open_amt = 0
	
	rect_size.x = 60 + (180 * open_amt)

func _input(ev):
	if (ev is InputEventScreenTouch or ev is InputEventMouseButton):
		if ev.pressed != true: return
		open = ev.position.x < rect_size.x and ev.position.y < rect_size.y
		yield(get_tree(),"idle_frame")
		get_node("Click").visible = !open
		get_node("../SidebarClick").visible = open