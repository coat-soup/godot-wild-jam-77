extends Node

class_name HierarchyUtil

static func get_child_of_type(root: Node, type: Variant) -> Node:
	for child in root.get_children():
		if is_instance_of(child, type):
			return child
	return null
	
