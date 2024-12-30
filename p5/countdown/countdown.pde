import java.util.ArrayList;
import java.util.Date;

PShader glitchShader;
ArrayList<GlitchLayer> layers;
PFont font;
long targetTime;
boolean isEnded = false;
int freakMode = 0;
String message = "";
final int FREAK_MODES = 5;

void setup() {
  size(1920, 1080, P2D);
  pixelDensity(2);
  
  // Initialize glitch shader
  glitchShader = loadShader("glitch.glsl");
  
  // Setup font
  font = createFont("Arial Bold", 128);
  textFont(font);
  textAlign(CENTER, CENTER);
  
  // Initialize layers for glitch effect
  layers = new ArrayList<GlitchLayer>();
  for (int i = 0; i < 5; i++) {
    layers.add(new GlitchLayer());
  }
  
  // Set target time to next year
  int nextYear = year() + 1;
  targetTime = new Date(nextYear - 1900, 0, 1).getTime();
}

void draw() {
  background(0);
  
  // Get remaining time
  long now = System.currentTimeMillis();
  long remaining = targetTime - now;
  
  if (remaining <= 0 && !isEnded) {
    isEnded = true;
    message = "HAPPY NEW YEAR!";
  }
  
  // Draw glitch layers
  shader(glitchShader);
  for (GlitchLayer layer : layers) {
    layer.update();
    layer.display();
  }
  resetShader();
  
  // Draw countdown or message
  fill(255);
  if (!isEnded) {
    String timeStr = formatTime(remaining);
    textSize(height/8);
    text(timeStr, width/2, height/2);
  } else {
    if (frameCount % 30 < 15) { // Blink effect
      textSize(height/6);
      text(message, width/2, height/2);
    }
    if (frameCount % 60 == 0) { // Change freak mode
      freakMode = (freakMode + 1) % FREAK_MODES;
      glitchShader.set("freakMode", freakMode);
    }
  }
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
    
    // Generate random gradient
    color c1 = color(random(100), random(255), random(255), random(255));
    color c2 = color(random(100), random(255), random(255), random(255));
    float angle = random(TWO_PI);
    
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
  
  void display() {
    glitchShader.set("texture", pg);
    glitchShader.set("pos", pos);
    image(pg, 0, 0);
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
