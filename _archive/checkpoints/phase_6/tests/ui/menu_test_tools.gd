class_name MenuTestTools
extends RefCounted

static func fixture(t):
	var root=load("res://app/app_root.tscn").instantiate()
	t.add_child(root)
	root.router.settle_transition()
	return root

static func active(root):
	return root.router.modals[-1] if not root.router.modals.is_empty() else root.router.current

static func find_button(node: Node,key: String) -> LBButton:
	if node is LBButton and node.text_key==key: return node
	for child in node.get_children():
		var found:=find_button(child,key)
		if found!=null: return found
	return null

static func click(t,root,key: String) -> void:
	var button:=find_button(active(root),key)
	t.check(button!=null,"visible connected button "+key)
	if button!=null: button.pressed.emit()
	root.router.settle_transition()
