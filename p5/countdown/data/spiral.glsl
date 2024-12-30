#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform vec4 pos;
uniform int freakMode;
uniform float time;
uniform vec2 gravityCenter;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.xy;
    vec2 center = gravityCenter / resolution;
    
    // Spiral gravity distortion
    float dist = distance(uv, center);
    float angle = atan(uv.y - center.y, uv.x - center.x);
    float spiral = sin(dist * 10.0 + time) * 0.1;
    vec2 spiralOffset = vec2(cos(angle + spiral), sin(angle + spiral)) * dist * 0.1;
    
    // Motion blur
    vec4 color = vec4(0.0);
    float samples = 8.0;
    for(float i = 0.0; i < samples; i++) {
        float t = i / samples;
        vec2 offset = spiralOffset * t;
        color += texture2D(texture, uv + offset);
    }
    color /= samples;
    
    // Color bleeding
    float bleed = sin(time * 0.001 + dist * 10.0) * 0.1;
    color.r = texture2D(texture, uv + spiralOffset * (1.0 + bleed)).r;
    color.g = texture2D(texture, uv + spiralOffset).g;
    color.b = texture2D(texture, uv + spiralOffset * (1.0 - bleed)).b;
    
    // Original glitch effects
    if (freakMode > 0) {
        vec2 glitchUV = uv;
        if (freakMode == 1) {
            glitchUV.x += sin(uv.y * pos.x) * 0.1;
        } else if (freakMode == 2) {
            glitchUV.y += cos(uv.x * pos.y) * 0.1;
        } else if (freakMode == 3) {
            glitchUV += sin(pos.xy * 0.01) * 0.1;
        } else if (freakMode == 4) {
            float d = distance(glitchUV, vec2(0.5));
            glitchUV *= 1.0 + sin(d * pos.z) * 0.2;
        }
        color = mix(color, texture2D(texture, glitchUV), 0.5);
    }
    
    gl_FragColor = color * vertColor;
}