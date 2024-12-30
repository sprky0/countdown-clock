import java.util.ArrayList;
import java.util.Calendar;
import processing.opengl.*;

PShader glitchShader, bufferShader;
ArrayList<GlitchLayer> layers;
PGraphics currentBuffer, previousBuffer;
PFont font;
long targetTime;
boolean isEnded = false;
int freakMode = 0;
String message = "";
final int FREAK_MODES = 5;
long endTime = 0;
PVector gravityCenter;

void setup() {
    //size(1920, 1080, P3D);
    fullScreen();
    pixelDensity(2);
    
    glitchShader = loadShader("glitch.glsl");
    bufferShader = loadShader("buffer.glsl");
    font = createFont("Arial Bold", 128);
    textFont(font);
    textAlign(CENTER, CENTER);
    
    currentBuffer = createGraphics(width, height, P3D);
    previousBuffer = createGraphics(width, height, P3D);
    
    layers = new ArrayList<GlitchLayer>();
    for (int i = 0; i < 5; i++) {
        layers.add(new GlitchLayer());
    }
    
    gravityCenter = new PVector(width/2, height/2);
    
    Calendar cal = Calendar.getInstance();
    cal.set(year() + 1, Calendar.JANUARY, 1, 0, 0, 0);
    targetTime = cal.getTimeInMillis();
}

void draw() {
    currentBuffer.beginDraw();
    currentBuffer.background(0);
    
    long now = System.currentTimeMillis();
    long remaining = targetTime - now;
    
    if (remaining <= 0 && !isEnded) {
        isEnded = true;
        endTime = now;
        message = "HAPPY NEW YEAR!";
    }
    
    float t = millis() * 0.001f;
    float radius = min(width, height) * 0.3f;
    gravityCenter.x = width/2 + cos(t) * radius * sin(t * 0.5f);
    gravityCenter.y = height/2 + sin(t) * radius * cos(t * 0.5f);
    
    glitchShader.set("time", t);
    glitchShader.set("gravityCenter", gravityCenter.x, gravityCenter.y);
    glitchShader.set("resolution", (float)width, (float)height);
    
    currentBuffer.shader(glitchShader);
    for (GlitchLayer layer : layers) {
        layer.update();
        layer.display(currentBuffer);
    }
    currentBuffer.resetShader();
    
    currentBuffer.fill(255, 200);
    if (!isEnded) {
        String timeStr = formatTime(remaining);
        currentBuffer.textSize(height/8);
        for(int i = 0; i < 3; i++) {
            float offset = sin(t + i) * 5;
            currentBuffer.text(timeStr, width/2 + offset, height/2 + offset);
        }
    } else {
        if (frameCount % 30 < 15) {
            currentBuffer.textSize(height/6);
            for(int i = 0; i < 3; i++) {
                float offset = sin(t + i) * 10;
                currentBuffer.text(message, width/2 + offset, height/2 + offset);
            }
            
            if (now - endTime > 60000) {
                currentBuffer.textSize(height/12);
                for(int i = 0; i < 3; i++) {
                    float offset = sin(t + i) * 7;
                    currentBuffer.text("OH SHIT! HERE WE GO AGAIN!", width/2 + offset, height/2 + height/4 + offset);
                }
            }
        }
        if (frameCount % 60 == 0) {
            freakMode = (freakMode + 1) % FREAK_MODES;
            glitchShader.set("freakMode", freakMode);
        }
    }
    currentBuffer.endDraw();
    
    // Apply buffer shader for reverb effect
    shader(bufferShader);
    bufferShader.set("previousFrame", previousBuffer);
    bufferShader.set("time", t);
    bufferShader.set("mixAmount", 0.5);
    image(currentBuffer, 0, 0);
    resetShader();
    
    // Swap buffers
    PGraphics temp = previousBuffer;
    previousBuffer = currentBuffer;
    currentBuffer = temp;
}

class GlitchLayer {
    PGraphics pg;
    float[] pos;
    float[] speed;
    
    GlitchLayer() {
        pg = createGraphics(width, height, P2D);
        pos = new float[4];
        speed = new float[4];
        randomize();
    }
    
    void randomize() {
        for (int i = 0; i < 4; i++) {
            pos[i] = random(2000);
            speed[i] = random(-50, 50);
        }
        
        pg.beginDraw();
        pg.background(0, 0);
        pg.noStroke();
        
        color c1 = color(random(100), random(255), random(255), random(255));
        color c2 = color(random(100), random(255), random(255), random(255));
        
        for (int i = 0; i < height; i++) {
            float inter = map(i, 0, height, 0, 1);
            color c = lerpColor(c1, c2, inter);
            pg.fill(c);
            pg.rect(0, i, width, 1);
        }
        pg.endDraw();
    }
    
    void update() {
        for (int i = 0; i < 4; i++) {
            pos[i] += speed[i];
            if (pos[i] < 2 || pos[i] > 500) {
                speed[i] *= -1;
            }
        }
        
        if (random(1) > 0.95) randomize();
    }
    
    void display(PGraphics buffer) {
        buffer.image(pg, 0, 0);
    }
}

String formatTime(long ms) {
    long seconds = ms / 1000;
    long minutes = seconds / 60;
    long hours = minutes / 60;
    long days = hours / 24;
    
    seconds %= 60;
    minutes %= 60;
    hours %= 24;
    
    return String.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds);
}
