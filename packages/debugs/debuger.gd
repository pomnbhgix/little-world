extends Node

@export var line:MeshInstance3D;

func draw_line(path):
	var im: ImmediateMesh = line.mesh;
	
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_POINTS, null)
	im.surface_add_vertex(path[0])
	im.surface_add_vertex(path[path.size() - 1])
	im.surface_end()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for current_vector in path:
		im.surface_add_vertex(current_vector)
	im.surface_end()
	

