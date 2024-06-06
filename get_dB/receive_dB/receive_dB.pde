import oscP5.*;
import netP5.*;

OscP5 oscP5;
OscP5 note;
float receivedValue = 0;

int smallSize = 50;
int mediumSize = 100;
int largeSize = 150;
int circleSize = mediumSize;
int lastChangeTime = 0;

// Variables para la bola roja
int redCircleSize = smallSize;

// Variable global para outputs
float[] outputs = new float[2];

void setup() {
  size(800, 400);
  colorMode(RGB, 1.0);
  oscP5 = new OscP5(this, 9001);  // Escuchar en el puerto 9001
  note = new OscP5(this, 12000);

  fill(1);
  textSize(32);
}

void draw() {
  background(0.75);
  fill(0);
  text("dB Level: " + nf(receivedValue, 1, 2), 20, 40);

  // Dibujar el círculo en el centro de la pantalla
  fill(1);  // Color blanco para el círculo principal
  ellipse(width/2, height/2, circleSize, circleSize);

  // Dibujar el círculo rojo solo si se cumple la condición
  if (outputs[0] > 0.9) {
    fill(1, 0, 0);  // Color rojo
    ellipse(width/2, height/2, redCircleSize, redCircleSize);
  }

  // Cambiar el tamaño del círculo principal cada 5 segundos
  if (millis() - lastChangeTime > 2000) {
    changeCircleSize();
    lastChangeTime = millis();
  }
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/wek/inputs") == true) {
    if (theOscMessage.checkTypetag("f")) {
      receivedValue = theOscMessage.get(0).floatValue();
      updateRedCircleSize();  // Actualizar el tamaño del círculo rojo
    }
  }
  if (theOscMessage.checkAddrPattern("/wek/outputs")) {
    for (int i = 0; i < 2; i++) {
      outputs[i] = theOscMessage.get(i).floatValue();
    }
  }
}

void changeCircleSize() {
  int randomSize = int(random(3));  // Generar un número aleatorio entre 0 y 2
  switch(randomSize) {
    case 0:
      circleSize = smallSize;
      break;
    case 1:
      circleSize = mediumSize;
      break;
    case 2:
      circleSize = largeSize;
      break;
  }
}

void updateRedCircleSize() {
  if (receivedValue >= -50 && receivedValue < -40) {
    redCircleSize = smallSize;
    //text("Piano Sound", 20, height/2);
  } else if (receivedValue >= -38 && receivedValue < -36) {
    redCircleSize = mediumSize;
    //text("Mezzo Forte", 20, height/2);
  } else if (receivedValue >= -34 && receivedValue <= -30) {
    redCircleSize = largeSize;
    //text("Fortissimo", 20, height/2);
  }
}
