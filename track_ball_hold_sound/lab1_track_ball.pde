import oscP5.*;
import netP5.*;

float diameter = 20;
float posX;
float posY;
float initialPosX = 100; // Posición inicial en el borde izquierdo
float initialPosY = 150; // Centro vertical del lienzo
OscP5 oscP5;
OscP5 face;

boolean desiredInput = false;
boolean hasSurpassedThresholdOnce = false;
float speed = 2.0; // Velocidad constante
boolean succeeded = false;
float angle = 0;
PVector targetPosition;

float face_value = 0;

void setup() {
  size(800, 300); // Lienzo más ancho
  colorMode(RGB, 1.0);
  stroke(0.0);

  posX = initialPosX;
  posY = initialPosY;

  // Inicializa oscP5
  oscP5 = new OscP5(this, 12000);  // 12000 es el puerto donde se recibirán los mensajes OSC
  face = new OscP5(this, 12001);

    targetPosition = new PVector(posX, posY);
}

void draw() {
  background(0.75);

  // Dibuja el circuito
  strokeWeight(2);
  // line(50, 100, 750, 100); // Línea superior
  line(50, 200, 750, 200); // Línea inferior
  strokeWeight(4);
  line(730, 120, 730, 180); // Línea doble derecha
  line(730, 120, 730, 180); // Línea doble derecha


   // Dibuja el círculo
  pushMatrix();
  translate(posX, posY);
  rotate(radians(angle));
  fill(0);
  ellipse(0, 0, diameter, diameter);
  popMatrix();

  // Mueve el círculo hacia la posición objetivo
  moveEllipseTowardsTarget();

  // Verifica colisiones
  checkCollision();
  
  // Muestra el face_value
  fill(0);
  textSize(16);
  textAlign(RIGHT, TOP);
  text("Face: " + face_value, width - 10, 10);
  
  // Muestra el mensaje de éxito si es necesario
  if (succeeded) {
    fill(0);
    textSize(32);
    text("Succeed", width / 2 - 50, height / 2 - 20);
  }
}

void oscEvent(OscMessage theOscMessage) {
  // Aquí se recibe el mensaje OSC. Supongamos que la salida de Wekinator está en la dirección "/wek/outputs"
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
  if (outputs[0] > 0.90 && face_value==1) {
    desiredInput = true;
    hasSurpassedThresholdOnce = true; // Marcar que el umbral se ha superado
    angle = 0;
    targetPosition = new PVector(posX + 10, posY);
  } else if (hasSurpassedThresholdOnce) {
    desiredInput = false;
    angle = 30;
    targetPosition = new PVector(posX + 10, posY + 10);
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
        targetPosition.x += 10; // Continuar moviendo a la derecha cuando se alcanza el objetivo
      }
    }
  }
}

void checkCollision() {
  // Verifica si la bola toca la línea inferior
  if (posY - diameter / 2 <= 100 || posY + diameter / 2 >= 200) {
    resetPosition();
  }

  // Verifica si la bola toca la línea doble
  if (posX + diameter / 2 >= 720) {
    succeeded = true;
  }
}

void resetPosition() {
  posX = initialPosX;
  posY = initialPosY;
  targetPosition = new PVector(posX, posY);
  angle = 0;
  succeeded = false;
  hasSurpassedThresholdOnce = false; // Reiniciar el indicador
}
