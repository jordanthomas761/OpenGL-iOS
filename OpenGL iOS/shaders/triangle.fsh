#version 300 es
precision highp float;
out vec4 FragColor;
in vec3 ourColor; // we set this variable in the OpenGL code.

uniform float mixture;
void main()
{
	FragColor = vec4(ourColor, 1.0);
}
