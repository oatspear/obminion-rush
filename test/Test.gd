extends Node2D

onready var human: KinematicBody2D = $YSort/Human
onready var orc: KinematicBody2D = $YSort/Orc

func _ready():
    human.set_patrol_path($Stage/Middle.get_path())
