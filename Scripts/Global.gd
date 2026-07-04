# Global.gd
extends Node

var money: int = 500

func add_money(amount: int) -> void:
	money += amount
	print("[Global] Dinero añadido: ", amount, " | Total: ", money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		print("[Global] Dinero gastado: ", amount, " | Restante: ", money)
		return true
	else:
		print("[Global] Fondos insuficientes. Tienes: ", money, " | Necesitas: ", amount)
		return false

func get_money() -> int:
	return money
