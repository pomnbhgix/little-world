@tool
extends MeshInstance3D

@export var update = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		generate_mesh()
		update = false

func generate_mesh():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	#######################################
	## Insert code here to generate mesh ##
	verts.resize(4)
	uvs.resize(4)
	normals.resize(4)
	indices.resize(6)
	
	# [(-0.5, 0, -0.5), (0.5, 0, -0.5), (-0.5, 0, 0.5), (0.5, 0, 0.5)]
	# [0, 2, 1, 1, 2, 3]
	
	verts[0] = Vector3.ZERO
	verts[1] = Vector3(1,0,0)
	verts[2] = Vector3(0,0,-1)
	verts[3] = Vector3(1,0,-1)
	
	normals[0] = Vector3.UP
	normals[1] = Vector3.UP
	normals[2] = Vector3.UP
	normals[3] = Vector3.UP
	
	uvs[0] = Vector2.ZERO
	uvs[1] = Vector2.RIGHT
	uvs[2] = Vector2(0.0,-1.0)
	
	indices[0] = 0
	indices[1] = 2
	indices[2] = 1
	indices[3] = 1
	indices[4] = 2
	indices[5] = 3
	#######################################

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
