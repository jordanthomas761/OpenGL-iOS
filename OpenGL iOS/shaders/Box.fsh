#version 300 es
precision highp float;
out vec4 FragColor;
in vec3 ourColor; // we set this variable in the OpenGL code.
in vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;
uniform float mixture;
void main()
{
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, vec2(1.0 - TexCoord.s, TexCoord.t)), mixture);
}
