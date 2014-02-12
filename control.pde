void mousePressed() {
  if (mouseButton == LEFT) {
  }
}

void mouseWheel(int D) {
  //println("mouse has moved by " + delta + " units.");
  menu.scrolled(D);
}

public void pause(int theValue) {
  println("a button event from colorC: "+theValue);
  song.pause();
  pause = true;
  cp5.controller("play").show();
  cp5.controller("home").show();
}

public void play(int theValue) {
  println("a button event from colorC: "+theValue);
  if (pause == true) { 
    song.play();
    menuOn = 2;
    pause = false;
    cp5.controller("pause").show();
  }
}
