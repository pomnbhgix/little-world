@tool
extends MeshInstance3D

@export var update = true
@export var test = true

@export var resolution:int = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		procedual_mesh()
		update =  false
	
func procedual_mesh():
	print_debug("procedual mesh")
	
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	#######################################
	## Insert code here to generate mesh ##
	
	#verts = PackedVector3Array([Vector3.ZERO,Vector3.RIGHT,Vector3.UP,Vector3(1,1,0)])
	#normals = PackedVector3Array([Vector3.BACK,Vector3.BACK,Vector3.BACK,Vector3.BACK])
	#uvs = PackedVector2Array([Vector2.ZERO,Vector2.RIGHT,Vector2.UP,Vector2(1,-1)])
	#indices = PackedInt32Array([0, 2, 1, 1, 2, 3])
	
	var resolution_v = resolution * 2; 
	var vertex_count = 5 * resolution_v * resolution + 2;
	var index_count = 6 * 5 * resolution_v * resolution;
	var job_length = 5 * resolution;
		
	verts.resize(vertex_count)
	normals.resize(vertex_count) 
	uvs.resize(vertex_count) 
	indices.resize(index_count) 
		
	for i in job_length:
		var u : int = i / 5;
		var strip = get_strip(i - 5 * u);
		var vi = resolution_v * (resolution * strip.id + u) + 2;
		var ti = 2 * resolution_v * (resolution * strip.id + u);
		var firstColumn = u == 0;
		
		var quad = Vector4i.ZERO;
		
		if firstColumn:
			if strip.id == 0:
				quad = Vector4i(vi, 0, 4 * resolution_v * resolution + 2, vi + 1)
			else:
				quad = Vector4i(vi, 0, vi - resolution_v * (resolution + u), vi + 1)
		else:
			quad = Vector4i(vi, vi - resolution_v, vi - resolution_v + 1, vi + 1)
		
		#var quad = Vector4i(
			#vi,
			#firstColumn if 0 else vi - resolution_v,
			#firstColumn if 
				#strip.id == 0 if 4 * resolution_v * resolution + 2 else vi - resolution_v * (resolution + u) 
			#else vi - resolution_v + 1,
			#vi + 1);
		
		u += 1;
		
		var columnBottomDir = strip.lowRightCorner - down();
		var columnBottomStart = down() + columnBottomDir * u / resolution;
		var columnBottomEnd = strip.lowLeftCorner + columnBottomDir * u / resolution;

		var columnLowDir = strip.highRightCorner - strip.lowLeftCorner;
		var columnLowStart = strip.lowRightCorner + columnLowDir * (float(u) / resolution - 1.0);
		var columnLowEnd = strip.lowLeftCorner + columnLowDir * u / resolution;

		var columnHighDir = strip.highRightCorner - strip.lowLeftCorner;
		var columnHighStart = strip.lowLeftCorner + columnHighDir * u / resolution;
		var columnHighEnd = strip.highLeftCorner + columnHighDir * u / resolution;

		var columnTopDir = up() - strip.highLeftCorner;
		var columnTopStart = strip.highRightCorner + columnTopDir * (float(u) / resolution - 1.0);
		var columnTopEnd = strip.highLeftCorner + columnTopDir * u / resolution;
		
		if i == 0:
			verts[0] = down()
			verts[1] = up()
		
		verts[vi] = columnBottomStart.normalized();
		vi += 1;
		
		var v:int = 1;
		
		
		while v < resolution_v:
			var pos = Vector3.ZERO;
			
			if v <= resolution - u:
				pos = lerp(columnBottomStart, columnBottomEnd, float(v) / resolution);
			elif (v < resolution):
				pos = lerp(columnLowStart, columnLowEnd, float(v) / resolution);
			elif (v <= resolution_v - u):
				pos = lerp(columnHighStart, columnHighEnd, float(v) / resolution - 1.0);
			else:
				pos = lerp(columnTopStart, columnTopEnd, float(v) / resolution - 1.0);
			
			verts[vi] = pos.normalized();
			
			print_debug(ti)
			
			indices.set(ti * 3,quad.x);
			indices.set(ti * 3 + 1,quad.y);
			indices.set(ti * 3 + 2,quad.z);
			
			indices.set((ti + 1) * 3,quad.x);
			indices.set((ti + 1) * 3 + 1, quad.z);
			indices.set((ti + 1) * 3 + 2, quad.w);
			
			quad.y = quad.z;
			
			if firstColumn && v <= resolution - u:
				quad += Vector4i(1, 0, resolution_v, 1)
			else:
				quad += Vector4i(1, 0, 1, 1)
				
			v += 1;
			vi += 1;
			ti += 2;
		
		if (!firstColumn):
			if strip.id == 0 :
				quad.z = resolution_v * resolution * 5  - resolution + u + 1;
			else :
				quad.z = resolution_v * resolution * strip.id - resolution + u + 1;
				
		if u < resolution:
			quad.w = quad.z + 1;
		else:
			quad.w = 1;
		
		#quad.w = u < resolution if quad.z + 1 else 1;
		
		#print_debug(ti)
		
		indices.set(ti * 3,quad.x);
		indices.set(ti * 3 + 1,quad.y);
		indices.set(ti * 3 + 2,quad.z);
		#
		indices.set((ti + 1) * 3,quad.x);
		indices.set((ti + 1) * 3 + 1, quad.z);
		indices.set((ti + 1) * 3 + 2, quad.w);
		
		#indices[ti * 3] = quad.x;
		#indices[ti * 3 + 1] = quad.y;
		#indices[ti * 3 + 2] = quad.z;
		#
		#indices[(ti + 1) * 3] = quad.x;
		#indices[(ti + 1) * 3 + 1] = quad.z;
		#indices[(ti + 1) * 3 + 2] = quad.w;
		
		#streams.SetTriangle(ti + 0, quad.xyz);
		#streams.SetTriangle(ti + 1, quad.xzw);
			#firstColumn ? 0 : vi - ResolutionV,
			#firstColumn ?
			#strip.id == 0 ?
			#4 * ResolutionV * Resolution + 2 :
			#vi - ResolutionV * (Resolution + u) :
			#vi - ResolutionV + 1,
		
	for i in vertex_count:
		normals[i] = verts[i].normalized()
	
	#######################################

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

func down()->Vector3:
	return Vector3(0.0,-1.0,0.0);
	
func up()->Vector3:
	return Vector3(0.0,1.0,0.0);

func get_strip(id:int):
	if id == 0 || id == 1 || id == 2 || id == 3 :
		return create_strip(id);
	else :
		return create_strip(4);

class Strip:
	var id:int;
	var lowLeftCorner:Vector3;
	var lowRightCorner:Vector3;
	var highLeftCorner:Vector3;
	var highRightCorner:Vector3;

func create_strip(id:int) -> Strip:
	var strip =  Strip.new();
	strip.id = id;
	strip.lowLeftCorner = get_corner(2 * id, -1);
	
	if id == 4:
		strip.lowRightCorner = get_corner(0, -1);
	else:
		strip.lowRightCorner = get_corner(2 * id + 2, -1);
	
	if id == 0:
		strip.highLeftCorner = get_corner(9, 1);
	else:
		strip.highLeftCorner = get_corner(2 * id - 1, 1);
		
	#strip.lowRightCorner = get_corner(id == 4 if 0 else 2 * id + 2, -1);
	#strip.highLeftCorner = get_corner(id == 0 if 9 else 2 * id - 1, 1);
	strip.highRightCorner = get_corner(2 * id + 1, 1);
	return strip;

func get_corner(id:int,ySign:int):
	var res = Vector3.ZERO;
	res.x = 0.4 * sqrt(5.0) * sin(0.2 * PI * id);
	res.y = ySign * 0.2 * sqrt(5.0);
	res.z = -0.4 * sqrt(5.0) * cos(0.2 * PI * id);
	return res;
	

