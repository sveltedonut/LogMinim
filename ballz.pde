class Ball {
  PVector P;
  PVector speed;
  PVector tMouse;
  float mouseDistance;
  boolean alive = true;
  Ball(boolean spawn, float x, float y) {
    P = new PVector(x, y);
    mouseDistance = dist(P.x, P.y, mouseX, mouseY);
    tMouse = new PVector((mouseX-P.x)/128, (mouseY-P.y)/128);
    if (spawn = false) {
      speed = new PVector(random(-(height/128), height/128), random(-(height/128), height/128));
    }
    else {
      speed = new PVector(random(height/1024)*64*(floor(random(2))*2-1), random(height/1024)*64*(floor(random(2))*2-1));
    }
  }
  void move() {
    P.add(speed);
    if (P.x > width/2 || P.x < 0) {
      if (P.x > width/2) {
        P.x = width/2;
      }
      else {
        P.x = 0;
      }
      speed.x *= - 1;
    }
    if (P.y > height || P.y < 0) {
      if (P.y > height) {
        P.y = height;
      }
      else {
        P.y = 0;
      }
      speed.y *= - 1;
    }
    mouseDistance = dist(P.x, P.y, mouseX, mouseY);
    tMouse.x = (mouseX-P.x)/128;
    if (mouseX > width/2) {
      tMouse.x = (width-mouseX-P.x)/128;
    }
    tMouse.y = (mouseY-P.y)/128;
  }
  void prog() {
    P.add(speed);
    if (P.x > width/2 || P.x < 0) {
      boolean alive = false;
    }
    if (P.y > height || P.y < 0) {
      boolean alive = false;
    }
  }
  void change() {
    speed.x = random(-(height/96), height/96);
    speed.y = random(-(height/96), height/96);
  }
}

public class Fw {
  PVector loc = new PVector();
  PVector speed = new PVector( random(-15, 15), random(-15, 15) );
  color col;
  boolean alive = true;
  int age = 0;
  int shape;

  public Fw( float x, float y, float mag, color col )
  {
    loc.x = x;
    loc.y = y; 
    speed.normalize();
    speed.mult(mag*2);
    this.col = col;
    shape = floor(random(3.99));
  }

  public void update()
  {
    age += 3;
    //loc.y += 0.5;
    loc.add( speed );
    if ( loc.y > height || loc.x > width || loc.y < 0 || loc.x < 0 || age > width/16) {
      alive = false;
    }
    fill(col);
    //for (int i = 0; i < fft.avgSize(); i++) {
    noStroke();
    //ellipse(loc.x, loc.y, fft.getAvg(i)*2, fft.getAvg(i)*2);
    switch(shape) {
    case 0:
      ellipse(loc.x, loc.y, random(height/64), random(height/64));
      break;
    case 1:
      triangle(random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64), random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64), random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64));
      break;
    case 2:
      rect(random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64), random(height/64), random(height/64));
      break;
    case 3:
      quad(random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64), random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64), random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64), random(loc.x-height/64, loc.x+height/64), random(loc.y-height/64, loc.y+height/64));
      break;
    }
  }
}

class halo {
  PVector loc = new PVector();
  color col;
  int age = 0;
}
