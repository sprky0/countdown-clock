#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D texture;
uniform sampler2D previousFrame;
uniform float time;
uniform float mixAmount;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
    vec2 uv = vertTexCoord.xy;
    vec4 currentFrame = texture2D(texture, uv);
    vec4 lastFrame = texture2D(previousFrame, uv);
    
    // Motion blur based on brightness
    float brightness = dot(currentFrame.rgb, vec3(0.299, 0.587, 0.114));
    float blurAmount = mix(0.1, 0.4, brightness);
    
    // Ghosting effect with time-based decay
    float decay = 0.85 + sin(time * 2.0) * 0.1;
    
    gl_FragColor = mix(currentFrame, lastFrame, decay * blurAmount) * vertColor;
}