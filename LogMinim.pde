import ddf.minim.analysis.*;
import ddf.minim.*;
import java.awt.event.*;
import controlP5.*;
import java.awt.event.*;
import java.io.File;
import processing.serial.*;

Minim minim;  
AudioPlayer song;
AudioMetaData meta;
FFT fftLog;
BeatDetect beat;
PFont font;
PImage ico;
ControlP5 cp5;
ListBox menu;
Serial port;
Ball ballI;
Ball ball2;
Ball ball3;
ArrayList balls = new ArrayList();
ArrayList fw = new ArrayList();
ArrayList halos = new ArrayList();

void setup()
{
  size(800, 600);
  colorMode(HSB, 360, 100, 100, 100);
  smooth();
  /*if (frame != null) {
    frame.setResizable(true);
  }*/
  //frame.setTitle("Visualizer");
  //ico = loadImage("playbg.png");
  //frame.setIconImage(ico.getImage());

  println(Serial.list());
  port = new Serial(this, "COM8", 115200);

  ballI = new Ball(false, random(width/2), height/2);
  ball2 = new Ball(false, random(width/2), random(height));
  ball3 = new Ball(false, random(width/2), random(height));

  initMenu();
  minim = new Minim(this);
  song = minim.loadFile("jingle.mp3", 2048);
  fftLog = new FFT(song.bufferSize(), song.sampleRate());
  fftLog.logAverages(28, 12);
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat.setSensitivity(300);
  loadItems();

  println(fftLog.avgSize());
  println(menu.getListBoxItems());
}

void draw()
{
  if (song.isPlaying()) {
    menu.clear();
    color col = color(random(360), random(100), random(50, 100));
    if (backChange > 0) {
      int transBackH = backH*backChange/backTime + tempBackH*(backTime - backChange)/backTime;
      int transBackS = backS*backChange/backTime + tempBackS*(backTime - backChange)/backTime;
      int transBackB = backB*backChange/backTime + tempBackB*(backTime - backChange)/backTime;
      fill(transBackH, transBackS, transBackB, 192);
    }
    else {
      fill(tempBackH, tempBackS, tempBackB);
      if (beat.isKick()) {
        backH = tempBackH;
        backS = tempBackS;
        backB = tempBackB;
        int h = int((frameCount%1024)/256);
        tempBackH = (int)(map(lmf[h]-16, 0, fftLog.avgSize(), 0, 540)+map(lmf[h]-16, 0, fftLog.avgSize(), 0, 540))/2;
        tempBackS = (int)((1-leftAvg/lm[h])*50+(1-rightAvg/rm[h])*50);
        tempBackB = ((int)leftAvg+(int)rightAvg);
        if (rm[0] > 15 || lm[0] > 15) {
          tempBackS = 255;
        }
        if (mixAvg < 5) {
          tempBackS /= 2;
          tempBackB = (rMaxFreq/2)+40;
        }
        backChange = (int)random(96, 192);
        backTime = backChange;
        fill(backH, backS, backB);
      }
    }
    rect(0, 0, width, height);
    beat.detect(song.mix);
    ballI.move();
    ball2.move();
    ball3.move();
    int portWrite = 1;

    if (beat.isKick()) {
      fill(map(lmf[0]-16, 0, fftLog.avgSize(), 0, 540), 100, leftAvg*4, 192);
      portWrite *= 2;
      switch((int)random(7)) {
      case 1:
        ballI.change();
        break;
      case 2:
        ball2.change();
        break;
      case 3:
        ball3.change();
        break;
      }
    }
    else {
      fill(map(lmf[0]-16, 0, fftLog.avgSize(), 0, 540), leftAvg*2, leftAvg/2, 10);
    }
    arc(width/2, height/2, leftAvg*2+height/2, leftAvg*2+height/2, (frameCount%1800)/5, (frameCount%1800)/5+QUARTER_PI+lm[0]/512, CHORD);
    if (beat.isSnare()) {
      fill(map(lmf[2]-16, 0, fftLog.avgSize(), 0, 540), 100, leftAvg*4, 192);
      portWrite *= 3;
      for ( int j = 0; j < abs(song.mix.level()*100); j++ )
      {
        float y = random(height/256);
        float x = random(height/256);
        fw.add( new Fw(x, y, song.mix.get(0)*height/16, color(lMaxFreq, 99, 99)));
        print(song.mix.get(0)*height/16);
        fw.add( new Fw(width - x, y, song.mix.get(0)*height/16, color(rMaxFreq, 99, 99)));
      }
    }
    else {
      fill(map(lmf[2]-16, 0, fftLog.avgSize(), 0, 540), leftAvg*2, leftAvg/2, 10);
    }
    arc(width/2, height/2, leftAvg*2+height/2, leftAvg*2+height/2, (frameCount%1440)/4, (frameCount%1440)/4+QUARTER_PI+lm[1]/384, CHORD);
    if (beat.isHat()) {
      fill(map(lmf[1]-16, 0, fftLog.avgSize(), 0, 540), 100, leftAvg*4, 192);
      portWrite *= 5;
    }
    else {
      fill(map(lmf[1]-16, 0, fftLog.avgSize(), 0, 540), leftAvg*2, leftAvg/2, 10);
    }
    arc(width/2, height/2, leftAvg*2+height/2, leftAvg*2+height/2, (frameCount%1080)/3, (frameCount%1080)/3+QUARTER_PI+lm[2]/320, CHORD);
    if (beat.isRange(7, 10, 1)) {
      fill(map(lmf[3]-16, 0, fftLog.avgSize(), 0, 540), 100, leftAvg*4, 192);
      portWrite *= 7;
    }
    else {
      fill(map(lmf[3]-16, 0, fftLog.avgSize(), 0, 540), leftAvg*2, leftAvg/2, 10);
    }
    arc(width/2, height/2, leftAvg*2+height/2, leftAvg*2+height/2, (frameCount%720)/2, (frameCount%720)/2+QUARTER_PI+lm[3]/256, CHORD);
    noStroke();
    fill(255);
    leftMax = rightMax = leftAvg = rightAvg = 0;
    for (int i = 0; i < fw.size(); i++) {
      Fw f = (Fw)fw.get(i);
      f.update();
      if ( !f.alive ) {
        fw.remove(f);
        i--;
      }
    }
    //print(" " + fw.size());
    int w = max(1, int(width/fftLog.avgSize()/2));

    backChange--;
    backFlow++;
    float songPos = song.position() / song.length();
    float relativePos = map(song.position(), 0, song.length(), 0, width - 32);

    for (int i = 0; i < 4; i++) {
      rm[i] = 0;
      lm[i] = 0;
      rmf[i] = 0;
      lmf[i] = 0;
    }

    fftLog.forward(song.right);
    for (int i = 0; i < fftLog.avgSize(); i++) {
      right[i] = fftLog.getAvg(i);
      rightMax = max(right[i], rightMax);
      if (rightMax == right[i]) {
        rMaxFreq = i;
      }
      rightAvg += right[i];
      if (i < 20) {
        rm[0] = max(right[i], rm[0]);
        if (rm[0] == right[i]) {
          rmf[0] = i;
        }
      } 
      else if (i >= 20 && i < 36) {
        rm[1] = max(right[i], rm[1]);
        if (rm[1] == right[i]) {
          rmf[1] = i;
        }
      } 
      else if (i >= 36 && i < 60) {
        rm[2] = max(right[i], rm[2]);
        if (rm[2] == right[i]) {
          rmf[2] = i;
        }
      } 
      else if (i >= 60 && i < 94) {
        rm[3] = max(right[i], rm[2]);
        if (rm[3] == right[i]) {
          rmf[3] = i;
        }
      }
    }
    rightAvg /= fftLog.avgSize();
    fftLog.forward(song.left);

    for (int i = 0; i < fftLog.avgSize(); i++) {
      left[i] = fftLog.getAvg(i);
      leftMax = max(left[i], leftMax);
      if (leftMax == left[i]) {
        lMaxFreq = i;
      }
      leftAvg += left[i];
      if (i < 20) {
        lm[0] = max(left[i], lm[0]);
        if (lm[0] == left[i]) {
          lmf[0] = i;
        }
      } 
      else if (i >= 20 && i < 36) {
        lm[1] = max(left[i], lm[1]);
        if (lm[1] == left[i]) {
          lmf[1] = i;
        }
      } 
      else if (i >= 36 && i < 60) {
        lm[2] = max(left[i], lm[2]);
        if (lm[2] == left[i]) {
          lmf[2] = i;
        }
      } 
      else if (i >= 60 && i < 94) {
        lm[3] = max(left[i], lm[2]);
        if (lm[3] == left[i]) {
          lmf[3] = i;
        }
      }
    }
    leftAvg /= fftLog.avgSize();
    mixAvg = (leftAvg+rightAvg)/2;
    mixMax = (leftMax+rightMax)/2;
    //print(" " + mixAvg);
    for (int i = (fftLog.avgSize()/4) + 24; i < fftLog.avgSize()*2/3; i++) {
      float lls = (1-leftAvg/left[i])*100;
      stroke(map(i-16, 0, fftLog.avgSize(), 0, 540), lls, left[i], left[i]);
      strokeWeight(max(left[i]/48, 1));
      float llx = map(left[i], 0, leftAvg*12, width/4, width/16);
      if (left[i] > max(50, leftAvg*2) && left[i-24] > max(50, leftAvg*2) && left[i+1] != left[i]) {
        line(llx, map(i-12, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width/4, map(i, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
        line(llx, map(i-12, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width/4, map(i-24, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
      }
      if (left[i] > max(50, leftAvg*2) && left[i-48] > max(50, leftAvg*2) && left[i+1] != left[i] && i >= (fftLog.avgSize()/4) + 48) {
        line(llx, map(i-24, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width/4, map(i, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
        line(llx, map(i-24, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width/4, map(i-48, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
      }
      float rls = (1-rightAvg/right[i])*100;
      stroke(map(i-16, 0, fftLog.avgSize(), 0, 540), rls, right[i], right[i]);
      strokeWeight(max(right[i]/48, 1));
      float rlx = map(right[i], 0, rightAvg*12, width*3/4, width*15/16);
      if (right[i] > max(50, rightAvg*2) && right[i-24] > max(50, rightAvg*2) && right[i+1] != right[i]) {
        line(rlx, map(i-12, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width*3/4, map(i, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
        line(rlx, map(i-12, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width*3/4, map(i-24, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
      }
      if (right[i] > max(50, rightAvg*2) && right[i-48] > max(50, rightAvg*2) && right[i+1] != right[i] && i >= (fftLog.avgSize()/4) + 48) {
        line(rlx, map(i-24, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width*3/4, map(i, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
        line(rlx, map(i-24, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4), width*3/4, map(i-48, fftLog.avgSize()/4, fftLog.avgSize()*2/3, height*3/4, height/4));
      }
    }
    noStroke();
    for (int i = fftLog.avgSize()/4; i < fftLog.avgSize()*2/3; i++) {
      if (left[i] > max(50, rightAvg*3/2) && left[i] != left[i-1] || i == lMaxFreq) {
        float lys = (1-leftAvg/left[i])*100;
        if (i == lMaxFreq && (1-leftAvg/left[i])*30 > left[i]) {
          fill(map(i-16, 0, fftLog.avgSize(), 0, 540), lys, 75, 75);
          float ly = map(i%12, 0, 12, height*3/4, height/4);
          ellipse(width/4, ly, (1-leftAvg/left[i])*30, left[i]);
        }
        else {
          fill(map(i-16, 0, fftLog.avgSize(), 0, 540), lys, left[i], left[i]);
          float ly = map(i%12, 0, 12, height*3/4, height/4);
          ellipse(width/4, ly, left[i], (1-leftAvg/left[i])*30);
        }
      }
      if (right[i] > max(50, rightAvg*3/2) && right[i] != right[i-1] || i == rMaxFreq) {
        float rys = (1-rightAvg/right[i])*100;
        if (i == rMaxFreq && (1-rightAvg/right[i])*30 > right[i]) {
          fill(map(i-16, 0, fftLog.avgSize(), 0, 540), rys, 75, 75);
          float ry = map(i%12, 0, 12, height*3/4, height/4);
          ellipse(width*3/4, ry, (1-rightAvg/right[i])*30, right[i]);
        }
        else {
          fill(map(i-16, 0, fftLog.avgSize(), 0, 540), rys, right[i], right[i]);
          float ry = map(i%12, 0, 12, height*3/4, height/4);
          ellipse(width*3/4, ry, right[i], (1-rightAvg/right[i])*30);
        }
      }
    }
    for (int i = 0; i < fftLog.avgSize(); i++) {
      if (left[i] > 30 && left[max(0, i-1)] != left[i] || i == lMaxFreq) {
        float les = (1-leftAvg/left[i])*100;
        fill(map(i-16, 0, fftLog.avgSize(), 0, 540), les, left[i], left[i]);
        float ls = 1.25 - leftAvg/50;
        rect(i*w, height - left[i]/height*768, w, height);
        ellipse(ballI.P.x, height/2, left[i]/height*512*ls, left[i]/height*512*ls);
        ellipse(ball2.P.x, ball2.P.y, left[i]/height*320*ls, left[i]/height*320*ls);
        ellipse(ball3.P.x, ball3.P.y, left[i]/height*192*ls, left[i]/height*192*ls);
      }
      if (right[i] > 30 && right[max(0, i-1)] != right[i] || i == rMaxFreq) {
        float res = (1-rightAvg/right[i])*100;
        fill(map(i-16, 0, fftLog.avgSize(), 0, 540), res, right[i], right[i]);
        float rs = 1.25 - rightAvg/100;
        rect(width-i*w, height - right[i]/height*768, w, height);
        ellipse(width-ballI.P.x, height/2, right[i]/height*512*rs, right[i]/height*512*rs);
        ellipse(width-ball2.P.x, ball2.P.y, right[i]/height*320*rs, right[i]/height*320*rs);
        ellipse(width-ball3.P.x, ball3.P.y, right[i]/height*192*rs, right[i]/height*192*rs);
      }
    }
    /*stroke(240, 99, 99);
     strokeWeight(1);
     line(0, height-mixAvg, width, height-mixAvg);
     stroke(0, 99, 99);
     //line(0, height-mixMax, width, height-mixMax);
     for(int i = 0; i < 4; i++){
     stroke(map(lmf[i]-16, 0, fftLog.avgSize(), 0, 540), 99, 99);
     line(0, height-lm[i], width, height-rm[i]);
     }
     line(20*w, 0, 20*w, height);
     line(36*w, 0, 36*w, height);
     line(60*w, 0, 60*w, height);
     noStroke();*/

    fill(128, 128);
    rect(16, 20, width-32, 4);
    fill(200, 99, 99, 128);
    ellipse(relativePos + 16, 22, 8, 8);
    menuOn = 1;
    pause = false;
    scrollPos = 0;
    cp5.controller("pause").setPosition(32, height-64);
    cp5.controller("play").hide();
    cp5.controller("home").hide();

    //for (int i = 0; i < Serial.list().length; i++) {
    //if (Serial.list()[i] == "COM8") {
    //port.write(portWrite);
    //}
    //}
    //print(" " + portWrite + " Port ");
    //beat.drawGraph(this);
  }
  else {
    if (pause == false || song.position() >= song.length()) {
      pause = false;
      song.rewind();
      song.pause();
      background(tempBackH, tempBackS, tempBackB, 192);
      loadItems();
    }
    menuOn = 0;
    menu.setSize(3*width/4, height);
    menu.setPosition(width/8, 0);
    if (pause == true && song.position() < song.length()) {
      cp5.controller("pause").hide();
    }
    cp5.controller("play").setPosition(32, height-64);
    cp5.controller("home").setPosition(96, height-64);
  }
  println(frameRate);
}

void stop()
{
  song.close();
  minim.stop();

  super.stop();
}
