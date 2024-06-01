import oscP5.*;
import netP5.*;

float diameter = 40;
float posX;
float posY;
float initialPosX = 300; // Centro del lienzo
float initialPosY = 150; // Centro del lienzo
float redCircleX;
float redCircleY;
OscP5 oscP5;
int lastChangeTime = 0;
int interval = 5000; // Intervalo de 5 segundos
boolean redCircleVisible = true;
float speed = 2.0; // Velocidad constante
PVector targetPosition;
int collisionCounter = 0; // Contador de colisiones

void setup() {
  size(600, 300); // Lienzo más ancho
  colorMode(RGB, 1.0);
  stroke(0.0);

  posX = initialPosX;
  posY = initialPosY;

  // Inicializa oscP5
  oscP5 = new OscP5(this, 12000);  // 12000 es el puerto donde se recibirán los mensajes OSC

  updateRedCirclePosition();
}

void draw() {
  background(0.75);

  // Dibuja el círculo gris
  fill(0);
  ellipse(posX, posY, diameter, diameter);

  // Dibuja el círculo rojo si es visible
  if (redCircleVisible) {
    fill(1.0, 0, 0); // Color rojo
    ellipse(redCircleX, redCircleY, 20, 20); // Diámetro de 20
  }

  // Verifica si han pasado 5 segundos para cambiar la posición del círculo rojo
  if (millis() - lastChangeTime > interval) {
    updateRedCirclePosition();
    lastChangeTime = millis();
  }

  // Mueve el círculo gris hacia la posición determinada por los inputs OSC
  moveEllipseTowardsTarget();
  checkCollision();
  
  // Muestra el contador de colisiones
  fill(0);
  textSize(16);
  text("Puntos: " + collisionCounter, 10, height - 10);
}

void updateRedCirclePosition() {
  // Coloca el círculo rojo en la izquierda o derecha del centro
  int position = int(random(2));
  if (position == 0) {
    redCircleX = width / 4; // Izquierda
    redCircleY = height / 2;
  } else {
    redCircleX = 3 * width / 4; // Derecha
    redCircleY = height / 2;
  }
  redCircleVisible = true;
}

void updateEllipse(float[] outputs) {
  // Determina la dirección basada en el valor del primer output
  if (outputs[0] > 0.90) {
    targetPosition = new PVector(3 * width / 4, height / 2); // Derecha
  } else if (outputs[1] > 0.8) {
    targetPosition = new PVector(width / 4, height / 2); // Izquierda
  } else {
    targetPosition = new PVector(width / 2, height / 2); // Centro
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
    }
  }
}

void checkCollision() {
  float distance = dist(posX, posY, redCircleX, redCircleY);
  if (distance < (diameter / 2 + 10)) {
    redCircleVisible = false;
    posX = initialPosX;
    posY = initialPosY;
    targetPosition = new PVector(initialPosX, initialPosY);
    lastChangeTime = millis(); // Reinicia el temporizador para cambiar la posición del círculo rojo
    collisionCounter++; // Incrementa el contador de colisiones
  }
}
