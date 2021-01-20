shader_type canvas_item;

uniform vec4 REPLACE_0_0 : hint_color;
uniform vec4 REPLACE_1_0 : hint_color;
uniform vec4 REPLACE_2_0 : hint_color;
uniform vec4 REPLACE_3_0 : hint_color;

const vec4 COLOR_0_0 = vec4(230.0/255.0, 69.0/255.0, 57.0/255.0, 1);
const vec4 COLOR_0_1 = vec4(173.0/255.0, 47.0/255.0, 69.0/255.0, 1);
const vec4 COLOR_0_2 = vec4(120.0/255.0, 29.0/255.0, 79.0/255.0, 1);
const vec4 COLOR_0_3 = vec4(79.0/255.0, 29.0/255.0, 76.0/255.0, 1);
const vec4 COLOR_1_0 = vec4(240.0/255.0, 181.0/255.0, 65.0/255.0, 1);
const vec4 COLOR_1_1 = vec4(207.0/255.0, 117.0/255.0, 43.0/255.0, 1);
const vec4 COLOR_1_2 = vec4(171.0/255.0, 81.0/255.0, 48.0/255.0, 1);
const vec4 COLOR_1_3 = vec4(125.0/255.0, 56.0/255.0, 51.0/255.0, 1);
const vec4 COLOR_2_0 = vec4(200.0/255.0, 212.0/255.0, 93.0/255.0, 1);
const vec4 COLOR_2_1 = vec4(99.0/255.0, 171.0/255.0, 63.0/255.0, 1);
const vec4 COLOR_2_2 = vec4(59.0/255.0, 125.0/255.0, 79.0/255.0, 1);
const vec4 COLOR_2_3 = vec4(47.0/255.0, 87.0/255.0, 83.0/255.0, 1);
const vec4 COLOR_3_0 = vec4(146.0/255.0, 232.0/255.0, 192.0/255.0, 1);
const vec4 COLOR_3_1 = vec4(79.0/255.0, 164.0/255.0, 184.0/255.0, 1);
const vec4 COLOR_3_2 = vec4(76.0/255.0, 104.0/255.0, 133.0/255.0, 1);
const vec4 COLOR_3_3 = vec4(58.0/255.0, 63.0/255.0, 94.0/255.0, 1);

void fragment() {
	vec4 REPLACE_0_1 = REPLACE_0_0 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_0_2 = REPLACE_0_1 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_0_3 = REPLACE_0_2 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_1_1 = REPLACE_1_0 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_1_2 = REPLACE_1_1 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_1_3 = REPLACE_1_2 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_2_1 = REPLACE_2_0 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_2_2 = REPLACE_2_1 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_2_3 = REPLACE_2_2 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_3_1 = REPLACE_3_0 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_3_2 = REPLACE_3_1 - vec4(.15, .15, .15, 0);
	vec4 REPLACE_3_3 = REPLACE_3_2 - vec4(.15, .15, .15, 0);
	COLOR = texture(TEXTURE, UV);
	if (COLOR == COLOR_0_0){
		COLOR = REPLACE_0_0;
	} else if (COLOR == COLOR_0_1){
		COLOR = REPLACE_0_1;
	} else if (COLOR == COLOR_0_2){
		COLOR = REPLACE_0_2;
	} else if (COLOR == COLOR_0_3){
		COLOR = REPLACE_0_3;
	} else if (COLOR == COLOR_1_0){
		COLOR = REPLACE_1_0;
	} else if (COLOR == COLOR_1_1){
		COLOR = REPLACE_1_1;
	} else if (COLOR == COLOR_1_2){
		COLOR = REPLACE_1_2;
	} else if (COLOR == COLOR_1_3){
		COLOR = REPLACE_1_3;
	} else if (COLOR == COLOR_2_0){
		COLOR = REPLACE_2_0;
	} else if (COLOR == COLOR_2_1){
		COLOR = REPLACE_2_1;
	} else if (COLOR == COLOR_2_2){
		COLOR = REPLACE_2_2;
	} else if (COLOR == COLOR_2_3){
		COLOR = REPLACE_2_3;
	} else if (COLOR == COLOR_3_0){
		COLOR = REPLACE_3_0;
	} else if (COLOR == COLOR_3_1){
		COLOR = REPLACE_3_1;
	} else if (COLOR == COLOR_3_2){
		COLOR = REPLACE_3_2;
	} else if (COLOR == COLOR_3_3){
		COLOR = REPLACE_3_3;
	}
}