class_name EnemySceneRegistry
extends RefCounted

const BASE_SCENE := preload("res://scenes/enemies/enemy_base.tscn")
const RAPTOR_SCENE := preload("res://scenes/enemies/raptor_scout.tscn")
const ROOT_VINE_SCENE := preload("res://scenes/enemies/root_vine.tscn")
const ORB_STALKER_SCENE := preload("res://scenes/enemies/orb_stalker.tscn")

func scene_for(definition: EnemyDefinition) -> PackedScene:
	match definition.family:
		EnemyDefinition.Family.DINOSAUR:
			return RAPTOR_SCENE
		EnemyDefinition.Family.PLANT:
			return ROOT_VINE_SCENE
		EnemyDefinition.Family.ALIEN:
			return ORB_STALKER_SCENE
		_:
			return BASE_SCENE
