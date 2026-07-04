# Global.gd
extends Node

signal money_changed(new_amount)
signal inventory_updated

var money: int = 500 : 
	set(val):
		money = val
		emit_signal("money_changed", money)

# Inventario global
var inventory: Dictionary = {}
var inventory_order: Array = []

func _ready() -> void:
	print("Global iniciado - Dinero: ", money)

# =============================================================
# FUNCIONES DE DINERO
# =============================================================
func add_money(amount: int) -> void:
	money += amount

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		return true
	return false

func get_money() -> int:
	return money

# =============================================================
# FUNCIONES DE INVENTARIO
# =============================================================
func add_item(item_id: String, amount: int = 1) -> void:
	if not inventory.has(item_id):
		inventory[item_id] = 0
		inventory_order.append(item_id)
	inventory[item_id] += amount
	emit_signal("inventory_updated")
	print("Item añadido: ", item_id, " x", amount, " - Total: ", inventory[item_id])

func remove_item(item_id: String, amount: int = 1) -> bool:
	if not inventory.has(item_id) or inventory[item_id] < amount:
		return false
	inventory[item_id] -= amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
		inventory_order.erase(item_id)
	emit_signal("inventory_updated")
	return true

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_count(item_id) >= amount

func get_inventory() -> Dictionary:
	return inventory

func get_inventory_order() -> Array:
	return inventory_order
