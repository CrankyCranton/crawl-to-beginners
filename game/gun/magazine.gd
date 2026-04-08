class_name Magazine extends Resource


@export var ammo_type: PackedScene
# Set ammo to a negative number to make it unlimitted.
@export var max_ammo: int = 6:
	set(value):
		max_ammo = value
		ammo = max_ammo

var ammo: int:
	set(value):
		ammo = mini(value, max_ammo)


func reload(from_mag: Magazine) -> void:
	if from_mag.ammo_type != ammo_type:
		printerr("Incorrect ammo type.")
		return
	if ammo < 0:
		return

	var loaded_ammo: int = max_ammo - ammo
	if from_mag.ammo >= 0:
		loaded_ammo = mini(loaded_ammo, from_mag.ammo)
	ammo += loaded_ammo
	from_mag.ammo -= loaded_ammo
