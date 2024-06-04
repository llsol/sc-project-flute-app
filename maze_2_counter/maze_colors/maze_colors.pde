import oscP5.*;
import netP5.*;

float diameter = 20;
float posX;
float posY;
float initialPosX = 75;
float initialPosY = 275;
OscP5 oscP5;
OscP5 face;

boolean desiredInput = false;
boolean hasSurpassedThresholdOnce = true;

float speed = 3.0;
boolean succeeded = false;
float angle = 0;
PVector targetPosition;

float face_value = 0;
float section = 1;
float nota = 0;

void setup() {
  size(800, 600);
  colorMode(HSB, 1.0); // Usamos el modo de color HSB para más flexibilidad
  strokeWeight(4);

  posX = initialPosX;
  posY = initialPosY;

  oscP5 = new OscP5(this, 12000);
  face = new OscP5(this, 12001);

  targetPosition = new PVector(posX, posY);
}

void draw() {
  background(0.6, 0.2, 0.95); // Fondo con color más claro

  stroke(2/3, 1, 0.5); // Color de las líneas del laberinto

  // Dibuja los carriles del laberinto
  line(50, 250, 300, 250);
  line(50, 300, 350, 300);
  line(300, 250, 300, 100);
  line(350, 300, 350, 150);
  line(300, 100, 500, 100);
  line(350, 150, 450, 150);
  line(450, 150, 450, 300);
  line(500, 100, 500, 250);
  line(500, 250, 650, 250);
  line(450, 300, 600, 300);
  line(600, 300, 600, 450);
  line(650, 250, 650, 400);
  line(650, 400, 750, 400);
  line(600, 450, 750, 450);

  // Dibuja el círculo
  pushMatrix();
  translate(posX, posY);
  rotate(radians(angle));
  fill(0.1, 0.8, 0.8); // Color del círculo
  ellipse(0, 0, diameter, diameter);
  popMatrix();

  moveEllipseTowardsTarget();
  checkCollision();
  
  fill(0);
  textSize(16);
  textAlign(RIGHT, TOP);
  text("Face: " + face_value, width - 10, 10);
  
  if (succeeded) {
    fill(0);
    textSize(60);
    textAlign(RIGHT, TOP);
    text("Succeed!", width - 50, 50);
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/wek/outputs")) {
    float[] outputs = new float[2];
    for (int i = 0; i < 2; i++) {
      outputs[i] = theOscMessage.get(i).floatValue();
    }
    updateEllipse(outputs);
  }
  if (theOscMessage.checkAddrPattern("/wek/face")) {
    int oscArg = int(theOscMessage.get(0).floatValue());
    face_value = oscArg;
  }
}

void updateEllipse(float[] outputs) {
  desiredInput = false;

  if (face_value == 1) {
    if (section == 2 && outputs[1] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX, posY - 10);
    } else if (section == 3 && outputs[0] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX + 10, posY);
    } else if (section == 4 && outputs[1] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX, posY + 10);
    } else if (section == 5 && outputs[0] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX + 10, posY);
    } else if (section == 6 && outputs[1] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX, posY + 10);
    } else if (section == 7 && outputs[0] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX + 10, posY);
    } else if (outputs[0] > 0.90) {
      desiredInput = true;
      angle = 0;
      targetPosition = new PVector(posX + 10, posY);
    } else if (hasSurpassedThresholdOnce) {
      desiredInput = false;
      angle = 30;
      targetPosition = new PVector(posX + 10, posY + 10);
    }
  }

  if (desiredInput) {
    hasSurpassedThresholdOnce = true;
  }
}

void moveEllipseTowardsTarget() {
  if (targetPosition != null) {
    float dx = targetPosition.x - posX;
    float dy = targetPosition.y - posY;
    float distance = dist(posX, posY, targetPosition.x, targetPosition.y);
    if (distance > speed) {
      posX += dx / distance * speed;
      posY += dy / distance * speed;
    } else {
      posX = targetPosition.x;
      posY = targetPosition.y;
      if (desiredInput) {
        targetPosition.x += 10; 
      }
    }
  }
}

void checkCollision() {
  boolean collision = false;

  switch ((int) section) {
    case 1:
      if (posY - diameter / 2 <= 250 && posX >= 50 && posX <= 300) {
        collision = true;
      }
      if (posY + diameter / 2 >= 300 && posX >= 50 && posX <= 350) {
        collision = true;
      }
      if (posX > 300) {
        section = 2;
      }
      break;
    case 2:
      if (posX - diameter / 2 <= 300 && posY >= 100 && posY <= 250) {
        collision = true;
      }
      if (posX + diameter / 2 >= 350 && posY >= 150 && posY <= 300) {
        collision = true;
      }
      if (posY < 100) {
        section = 3;
      }
      if (collision) {
        resetPosition(325, 275);
      }
      break;
    case 3:
      if (posY - diameter / 2 <= 100 && posX >= 300 && posX <= 500) {
        collision = true;
      }
      if (posY + diameter / 2 >= 150 && posX >= 350 && posX <= 450) {
        collision = true;
      }
      if (posX > 500) {
        section = 4;
      }
      if (collision) {
        resetPosition(325, 125);
      }
      break;
    case 4:
      if (posX - diameter / 2 <= 450 && posY >= 150 && posY <= 300) {
        collision = true;
      }
      if (posX + diameter / 2 >= 500 && posY >= 100 && posY <= 250) {
        collision = true;
      }
      if (posY > 250) {
        section = 5;
      }
      if (collision) {
        resetPosition(475, 125);
      }
      break;
    case 5:
      if (posY + diameter / 2 >= 300 && posX >= 450 && posX <= 600) {
        collision = true;
      }
      if (posY - diameter / 2 <= 250 && posX >= 500 && posX <= 650) {
        collision = true;
      }
      if (posX > 600) {
        section = 6;
      }
      if (collision) {
        resetPosition(475, 275);
      }
      break;
    case 6:
      if (posX - diameter / 2 <= 600 && posY >= 300 && posY <= 450) {
        collision = true;
      }
      if (posX + diameter / 2 >= 650 && posY >= 250 && posY <= 400) {
        collision = true;
      }
      if (posY > 450) {
        section = 7;
      }
      if (collision) {
        resetPosition(625, 275);
      }
      break;
    case 7:
      if (posY + diameter / 2 >= 450 && posX >= 600 && posX <= 750) {
        collision = true;
      }
      if (posY - diameter / 2 <= 400 && posX >= 650 && posX <= 750) {
        collision = true;
      }
      if (posX > 750) {
        succeeded = true;
      }
      if (collision) {
        resetPosition(625, 425);
      }
      break;
  }

  if (collision && section != 2 && section != 3 && section != 4 && section != 5 && section != 6 && section != 7) {
    resetPosition(initialPosX, initialPosY);
  }
}

void resetPosition(float newPosX, float newPosY) {
  posX = newPosX;
  posY = newPosY;
  targetPosition = new PVector(posX, posY);
  angle = 0;
  succeeded = false;
  hasSurpassedThresholdOnce = false;
}
