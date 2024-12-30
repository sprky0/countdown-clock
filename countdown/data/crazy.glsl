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

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void main() {
    vec2 uv = vertTexCoord.xy;
    vec4 color = texture2D(texture, uv);
    
    // Intense scanlines
    float scanline = sin(uv.y * 400.0 + time * 20.0) * 0.15;
    color.rgb += vec3(scanline);
    
    // Aggressive RGB Split
    float rgbOffset = sin(time * 4.0) * 0.05;
    color.r = texture2D(texture, uv + vec2(rgbOffset, rgbOffset)).r;
    color.g = texture2D(texture, uv).g;
    color.b = texture2D(texture, uv - vec2(rgbOffset, -rgbOffset)).b;
    
    // Large block glitches
    vec2 blockUV = floor(uv * 30.0);
    float blockNoise = random(blockUV + floor(time * 8.0));
    if(blockNoise > 0.95) {
        uv.x = fract(uv.x + 0.2);
        color = texture2D(texture, uv);
        color.rgb *= vec3(1.2, 0.8, 1.0); // Color tint on glitch
    }
    
    // Multiple wave distortions
    float wave1 = sin(uv.y * 40.0 + time * 3.0) * 0.006;
    float wave2 = cos(uv.x * 30.0 - time * 5.0) * 0.004;
    color += texture2D(texture, uv + vec2(wave1, wave2)) * 0.3;
    
    // Vertical tear lines
    float tearNoise = step(0.96, random(vec2(floor(uv.y * 80.0), time)));
    color.rgb = mix(color.rgb, vec3(1.0), tearNoise * 0.5);
    
    // Dynamic static noise
    float staticNoise = random(uv + time) * (0.1 + sin(time) * 0.05);
    color.rgb += vec3(staticNoise);
    
    // Color shift on edges
    float edgeNoise = random(uv * 2.0 + time);
    if(edgeNoise > 0.98) {
        color.rgb = color.gbr;
    }
    
    // VHS tracking distortion
    float tracking = sin(uv.y * 10.0 + time) * sin(time * 2.0) * 0.02;
    color.rgb += texture2D(texture, uv + vec2(tracking, 0.0)).rgb * 0.2;
    
    gl_FragColor = color * vertColor;
}
