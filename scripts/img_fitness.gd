extends Node

var textures := [
	preload("res://textures/tex1.png"),
	preload("res://textures/output.png"),
	preload("res://textures/tex1.png"),
	preload("res://textures/Sprite-0004.png"),
	
]

func _ready() -> void:
	var img1: Image = textures[0].get_image()
	var img2: Image = textures[3].get_image()

	var h = histogram_similarity(img1, img2)
	var f = frequency_similarity(img1, img2)

	print("+----------------- FITNESS:------------------+")
	print("histogram similarity: ", h)
	print("freq similarity: ", f)
	
	var fit = 0.7 * h + 0.3 * f
	print("fitness: ", fit)
	
	
	


func compute_histogram(image: Image, bins := 64):
	var hist = []
	hist.resize(bins)

	for i in range(bins):
		hist[i] = 0.0

	var total = image.get_width() * image.get_height()

	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var v = image.get_pixel(x, y).r
			var idx = int(v * (bins - 1))
			hist[idx] += 1.0

	for i in range(bins):
		hist[i] /= total

	return hist


func histogram_similarity(img1: Image, img2: Image):
	var h1 = compute_histogram(img1)
	var h2 = compute_histogram(img2)

	var error = 0.0

	for i in range(h1.size()):
		var diff = h1[i] - h2[i]
		error += diff * diff

	return 1.0 / (1.0 + error)


func compute_frequency_signature(image: Image, step := 8) -> Array:
	var w = image.get_width()
	var h = image.get_height()

	var freq = []

	for x in range(0, w, step):
		for y in range(0, h, step):
			var v = image.get_pixel(x, y).r
			freq.append(v)

	return freq


func frequency_similarity(img1: Image, img2: Image) -> float:
	var f1 = compute_frequency_signature(img1)
	var f2 = compute_frequency_signature(img2)

	var size = min(f1.size(), f2.size())

	var error = 0.0

	for i in range(size):
		var diff = f1[i] - f2[i]
		error += diff * diff

	return 1.0 / (1.0 + error)
