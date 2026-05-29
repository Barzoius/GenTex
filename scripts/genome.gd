extends RefCounted

class_name Genome

var octaves: int
var amplitude: float
var frequency: float

var warp_factor: float;

var parent1 = null
var parent2 = null

var fitness = 0

func _init(o: int, a: float, f: float, w: float):
	octaves = o
	amplitude = a
	frequency = f
	warp_factor = w
