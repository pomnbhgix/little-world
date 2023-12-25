extends Node

class_name Utils;

static func custom_quaternion(from:Vector3,to:Vector3)->Quaternion:
	var dot = from.dot(to)
	
	if dot < -0.999999:
		var tmpvec3 = Vector3(1,0,0).cross(from)
		if tmpvec3.length() < 0.000001:
			tmpvec3 = Vector3(0,1,0).cross(from)
		tmpvec3 = tmpvec3.normalized()
		return Quaternion(tmpvec3.x,tmpvec3.y,tmpvec3.z,0)
	
	elif dot > 0.999999:
		return Quaternion(0,0,0,1)
		
	else:
		var tmpvec3 = from.cross(to)
		return Quaternion(tmpvec3.x,tmpvec3.y,tmpvec3.z,1 + dot)
