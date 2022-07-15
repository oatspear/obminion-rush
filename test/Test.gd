extends Node2D

const SCN_PROJECTILE = preload("res://scenes/objects/Projectile.tscn")

onready var human1: KinematicBody2D = $YSort/Human
onready var human2: KinematicBody2D = $YSort/Human2
onready var human3: KinematicBody2D = $YSort/HumanArcher
onready var orc: KinematicBody2D = $YSort/Orc

func _ready():
    #human1.set_patrol_path($Stage/Middle.get_path())
    #human2.set_patrol_path($Stage/Middle.get_path())
    human3.set_patrol_path($Stage/Middle.get_path())
    human3.connect("spawn_projectile", self, "_on_spawn_projectile")

    orc.set_patrol_path($Stage/Middle.get_path())


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
