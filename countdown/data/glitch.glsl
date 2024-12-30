#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform vec4 pos;
uniform int freakMode;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  vec2 uv = vertTexCoord.xy;
  
  // Apply different distortion based on freak mode
  if (freakMode == 1) {
    uv.x += sin(uv.y * pos.x) * 0.1;
  } else if (freakMode == 2) {
    uv.y += cos(uv.x * pos.y) * 0.1;
  } else if (freakMode == 3) {
    uv += sin(pos.xy * 0.01) * 0.1;
  } else if (freakMode == 4) {
    float d = distance(uv, vec2(0.5));
    uv *= 1.0 + sin(d * pos.z) * 0.2;
  }
  
  // Clamp UV coordinates
  uv = clamp(uv, 0.0, 1.0);
  
  // Sample texture with distorted coordinates
  vec4 col = texture2D(texture, uv);
  
  // RGB shift
  float shift = sin(pos.w * 0.01) * 0.01;
  col.r = texture2D(texture, uv + vec2(shift, 0.0)).r;
  col.b = texture2D(texture, uv - vec2(shift, 0.0)).b;
  
  gl_FragColor = col * vertColor;
}