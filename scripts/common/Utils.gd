const FLOAT_EPSILON = 0.00001

static func compare_floats(a: float, b: float, epsilon = FLOAT_EPSILON):
	return abs(a - b) <= epsilon
