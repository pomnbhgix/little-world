extends Node

class_name ProceduralMeshesUtils;


class MeshData:
	var surface_array = []
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	func verts_data_resize(size: int):
		verts.resize(size)
		uvs.resize(size)
		normals.resize(size)
	
	func set_triangle(index,x,y,z):
		indices[index * 3] = x;
		indices[index * 3 + 1] = y;
		indices[index * 3 + 2] = z;
	
	func get_array_mesh_data() -> Array:	# Assign arrays to surface array.
		surface_array.resize(ArrayMesh.ARRAY_MAX)
		surface_array[Mesh.ARRAY_VERTEX] = verts
		surface_array[Mesh.ARRAY_TEX_UV] = uvs
		surface_array[Mesh.ARRAY_NORMAL] = normals
		surface_array[Mesh.ARRAY_INDEX] = indices
		return surface_array

static func generate_plane(resolution:int) -> Array:
	var vertex_count = (resolution + 1) * (resolution + 1);
	var index_count = 6 * resolution * resolution;
	
	var mesh_data = MeshData.new();
	mesh_data.verts_data_resize(vertex_count)
	mesh_data.normals.fill(Vector3(0.0,1.0,0.0))
	mesh_data.indices.resize(index_count)
	
	for z in (resolution + 1):
		var vi = (resolution + 1) * z
		var ti = 2 * resolution * (z - 1)
		
		var uv_y = float(z) / resolution;
		var vertex_z = uv_y - 0.5;
		mesh_data.verts[vi] = Vector3(-0.5,0.0,-vertex_z);
		mesh_data.uvs[vi] = Vector2(0,-uv_y);
		vi += 1;
		
		
		var x = 1;
		while x <= resolution:
			
			mesh_data.verts[vi] = Vector3(
				float(x) / resolution - 0.5,
				0.0,
				-vertex_z);
			mesh_data.uvs[vi] = Vector2(
				float(x) / resolution,
				-uv_y);
			
			if z > 0:
				#mesh_data.set_triangle(ti,0,2,1)
				#mesh_data.set_triangle(ti+3,1,2,3)
				mesh_data.set_triangle(ti,
					vi + (-resolution - 2),
					vi + (-1),
					vi + (-resolution - 1))
				mesh_data.set_triangle(ti + 1,
					vi + (-resolution - 1),
					vi + (-1),
					vi)
			
			x += 1;
			vi += 1;
			ti += 2;
		
	return mesh_data.get_array_mesh_data()






