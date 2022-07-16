extends Node2D

const SCN_PROJECTILE = preload("res://scenes/objects/Projectile.tscn")

const FRAMES_HUMAN_R = preload("res://data/animation/Human.tres")
const FRAMES_HUMAN_G = preload("res://data/animation/HumanGreen.tres")

onready var human1: KinematicBody2D = $YSort/Human
onready var human2: KinematicBody2D = $YSort/Human2
onready var human3: KinematicBody2D = $YSort/HumanArcher
onready var orc: KinematicBody2D = $YSort/Orc

onready var buttons = [
    $BattleGUI/ActionButton1,
    $BattleGUI/ActionButton2,
    $BattleGUI/ActionButton3,
]

func _ready():
    #human1.set_patrol_path($Stage/Paths/Path2.get_path())
    #human2.set_patrol_path($Stage/Paths/Path2.get_path())
    human3.set_patrol_path($Stage/Paths/Path2.get_path())
    human3.connect("spawn_projectile", self, "_on_spawn_projectile")

    orc.set_patrol_path($Stage/Paths/Path2.get_path())

    for i in range(len(buttons)):
        buttons[i].connect("button_clicked", self, "_on_button_clicked", [i])

    buttons[0].set_unit(human1.sprite.frames, human1.cost)
    buttons[1].set_unit(human2.sprite.frames, human2.cost)
    buttons[2].set_unit(human3.sprite.frames, human3.cost)


func _on_spawn_projectile(projectile, source, target):
    match projectile:
        Global.Projectiles.ARROW:
            _spawn_projectile(SCN_PROJECTILE, source, target)
        _:
            pass


func _spawn_projectile(scene, source, target):
    var obj = scene.instance()
    obj.position = source.position
    obj.target = target.get_hitbox_position()
    obj.power = source.power
    obj.collision_layer = 0
    obj.collision_mask = ~(1 << source.team)
    $YSort.add_child(obj)


func _on_button_clicked(i: int):
    print("Button ", i, " clicked.")
    buttons[i].disable()
