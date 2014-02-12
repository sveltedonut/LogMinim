void initMenu() {
  font = loadFont("AgencyFB-Reg-32.vlw");
  textFont(font);

  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
    }
  }
  );

  fill(tempBackH, tempBackS, tempBackB, 168);
  rect(0, 0, width, height);

  ControlP5.printPublicMethodsFor(ListBox.class);
  cp5 = new ControlP5(this);
  cp5.setControlFont(font);
  menu = cp5.addListBox("Song Selection")
    .setPosition(width/8, 0)
      .setSize(3*width/4, height)
        .setItemHeight(40)
          .setBarHeight(40)
            .setColorBackground(color(200, 99, 99, 128))
              .setColorActive(color(200, 99, 40, 128))
                .setColorForeground(color(200, 99, 60, 128))
                  .toUpperCase(false);
  ;
  menu.captionLabel().toUpperCase(true);
  menu.captionLabel().set("Song Selection");
  menu.captionLabel().setColor(color(0, 0, 0, 128));
  menu.captionLabel().style().marginTop = 0;
  menu.valueLabel().style().marginTop = 40;
  menu.showScrollbar();

  cp5.addButton("pause")
    .setValue(10)
      .setPosition(32, height-64)
        .setSize(74, 32)
          .setColorBackground(color(200, 99, 99, 128))
            .setColorActive(color(200, 99, 40, 128))
              .setColorForeground(color(200, 99, 60, 128));
  cp5.addButton("play")
    .setValue(31)
      .setPosition(32, height-64)
        .setSize(64, 32)
          .setColorBackground(color(200, 99, 99, 128))
            .setColorActive(color(200, 99, 40, 128))
              .setColorForeground(color(200, 99, 60, 128));
  cp5.addButton("home")
    .setValue(24)
      .setPosition(96, height-64)
        .setSize(64, 32)
          .setColorBackground(color(200, 99, 99, 128))
            .setColorActive(color(200, 99, 40, 128))
              .setColorForeground(color(200, 99, 60, 128));
}

void controlEvent(ControlEvent theEvent) {
  /* events triggered by controllers are automatically forwarded to
   the controlEvent method. by checking the name of a controller one can
   distinguish which of the controllers has been changed.
   */

  /* check if the event is from a controller otherwise you'll get an error
   when clicking other interface elements like Radiobutton that don't support
   the controller() methods
   */

  //println(theEvent.group().value()+" from "+theEvent.group());
  if (theEvent.isGroup() && theEvent.name().equals("Song Selection")) {
    if (mouseButton == LEFT) {
      if ((int)theEvent.group().value() == 0) {
        selectInput("Select file to visualize/ Sélectionne un fichier", "fileSelected");
      }
    }
  }
  if (theEvent.isController()) {
    print("control event from : "+theEvent.controller().name());
    println(", value : "+theEvent.controller().value());
  }
}
void loadItems() {
  try {
    ListBoxItem foobar = menu.getItem(0);
  }
  catch (Exception e) {
    ListBoxItem lb = menu.addItem("Select/Sélection", 0);
    lb.setColorBackground(color(200, 99, 99, 128));
  }
}
