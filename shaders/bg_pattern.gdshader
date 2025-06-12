shader_type canvas_item;

uniform float speed = 0.08;
uniform float speed2 = 0.03;

void vertex() {
	UV.x += TIME * speed2;
	UV.y += sin(TIME) * speed + TIME * speed2;
}