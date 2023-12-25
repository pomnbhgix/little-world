@tool
extends MeshInstance3D

@export var update = true;
@export var noise = FastNoiseLite.new()
@export var height_multiplier = 10.0;




@export var curve:Curve;
@export_range(0,1) var max_height:float = 0.5;


func _process(_delta):
	if update:
		
		
		generate_plane()

#		var surface_array =  ProceduralMeshesUtils.generate_plane(1)
#		print_debug(surface_array[ArrayMesh.ARRAY_VERTEX])
#		print_debug(surface_array[ArrayMesh.ARRAY_INDEX])
#		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
		
		update = false;

	
func generate_plane():
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

func update_mesh():
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(mesh,0)
	var data = surface_tool.commit_to_arrays()
	
	var vertices = data[ArrayMesh.ARRAY_VERTEX]
	var index_array = data[ArrayMesh.ARRAY_INDEX]
	var normals_array = data[ArrayMesh.ARRAY_NORMAL]
		
	for i in vertices.size():
		var vertex = vertices[i]
		vertices[i].y = caluculate_height(vertex.x,vertex.z) * height_multiplier
	
	var triangleCount = index_array.size() / 3
	for i in triangleCount:
		var normal_index = i * 3;
		var vertex_index_0 = index_array[normal_index]
		var vertex_index_1 = index_array[normal_index + 1]
		var vertex_index_2 = index_array[normal_index + 2]
		
		var normal = surface_normal(vertices[vertex_index_0],vertices[vertex_index_1],vertices[vertex_index_2])
		
		normals_array[vertex_index_0] += normal;
		normals_array[vertex_index_1] += normal;
		normals_array[vertex_index_2] += normal;
	
	for i in normals_array.size():
		normals_array[i] = normals_array[i].normalized()
	
	data[ArrayMesh.ARRAY_VERTEX] = vertices
	data[ArrayMesh.ARRAY_NORMAL] = normals_array
		
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,data)
	
	surface_tool.create_from(array_mesh,0)
	mesh = surface_tool.commit()
	
func caluculate_height(x,y):
	print_debug(x + 25.0,y + 25.0)
	var value = sample_noise_2d(x + 25.0,y + 25.0) - FalloffGenerator.evaluate_falloff(x,y,50.0,50.0)
	
	return clampf(value,0.0,1.0)
	

func surface_normal(x:Vector3,y:Vector3,z:Vector3): 
	var sidexy =  y - x;
	var sidexz =  z - x;
	return sidexz.cross(sidexy).normalized()

func sample_noise_2d(x:float,y:float) -> float:
	var value = curve.sample(noise.get_noise_2d(x,y))
	
	if value > max_height:
		return max_height;
	
	return value
	
	
