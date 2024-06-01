import oscP5.*;
import netP5.*;

float diameter = 20;
float posX;
float posY;
float initialPosX = 75; // Nueva posición inicial en el borde izquierdo del carril
float initialPosY = 275; // Centro vertical del carril
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
  size(800, 600); // Lienzo más grande para el laberinto
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

  // Dibuja los carriles del laberinto
  strokeWeight(2);
  // Sección 1
  line(50, 250, 300, 250); // Carril horizontal superior
  line(50, 300, 350, 300); // Carril horizontal inferior
  
  // Sección 2
  line(300, 250, 300, 100); // Carril vertical izquierdo
  line(350, 300, 350, 150); // Carril vertical derecho
  
  // Sección 3
  line(300, 100, 500, 100); // Carril horizontal superior
  line(350, 150, 450, 150); // Carril horizontal inferior
  
  // Sección 4
  line(450, 150, 450, 300); // Carril vertical izquierdo
  line(500, 100, 500, 250); // Carril vertical derecho
  
  // Sección 5
  line(500, 250, 650, 250); // Carril horizontal inferior
  line(450, 300, 600, 300); // Carril horizontal superior
  
  // Sección 6
  line(600, 300, 600, 450); // Carril vertical izquierdo
  line(650, 250, 650, 400); // Carril vertical derecho
  
  // Sección 7
  line(650, 400, 750, 400); // Carril horizontal superior
  line(600, 450, 750, 450); // Carril horizontal inferior

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
    //println("Received OSC outputs: " + outputs[0] + ", " + outputs[1]);
    updateEllipse(outputs);
  }
  if (theOscMessage.checkAddrPattern("/wek/face")) {
    int oscArg = int(theOscMessage.get(0).floatValue());
    face_value = oscArg;
    //println("Received OSC face value: " + face_value);
  }
}

void updateEllipse(float[] outputs) {
  if (outputs[0] > 0.90 && face_value == 1) {
    desiredInput = true;
    hasSurpassedThresholdOnce = true; // Marcar que el umbral se ha superado
    angle = 0;
    targetPosition = new PVector(posX + 10, posY);
    println("Desired input received, moving right");
  } else if (hasSurpassedThresholdOnce) {
    desiredInput = false;
    angle = 30;
    targetPosition = new PVector(posX + 10, posY + 10);
    println("Moving diagonally down-right");
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
      println("Moving towards target: (" + posX + ", " + posY + ")");
    } else {
      posX = targetPosition.x;
      posY = targetPosition.y;
      println("Reached target: (" + posX + ", " + posY + ")");
      if (desiredInput) {
        // Aumenta la posición objetivo en el eje X para mover hacia la derecha continuamente
        targetPosition.x += 10; 
      }
    }
  }
}

void checkCollision() {
  boolean collision = false;
  
  // Verifica colisiones con las paredes del carril
  // Sección 1
  if (posY - diameter / 2 <= 250 && posX >= 50 && posX <= 300) {
    collision = true; // Carril horizontal inferior
  }
  /*
  if (posY + diameter / 2 >= 300 && posX >= 50 && posX <= 350) {
    collision = true; // Carril horizontal superior
  }

  // Sección 2
  if (posX - diameter / 2 <= 300 && posY >= 100 && posY <= 250) {
    collision = true; // Carril vertical izquierdo
  }
  if (posX + diameter / 2 >= 350 && posY >= 150 && posY <= 300) {
    collision = true; // Carril vertical derecho
  }

  // Sección 3
  if (posY - diameter / 2 <= 100 && posX >= 300 && posX <= 500) {
    collision = true; // Carril horizontal superior
  }
  if (posY + diameter / 2 >= 150 && posX >= 350 && posX <= 450) {
    collision = true; // Carril horizontal inferior
  }

  // Sección 4
  if (posX - diameter / 2 <= 450 && posY >= 150 && posY <= 300) {
    collision = true; // Carril vertical izquierdo
  }
  if (posX + diameter / 2 >= 500 && posY >= 100 && posY <= 250) {
    collision = true; // Carril vertical derecho
  }

  // Sección 5
  if (posY + diameter / 2 >= 300 && posX >= 450 && posX <= 600) {
    collision = true; // Carril horizontal superior
  }
  if (posY - diameter / 2 <= 250 && posX >= 500 && posX <= 650) {
    collision = true; // Carril horizontal inferior
  }

  // Sección 6
  if (posX - diameter / 2 <= 600 && posY >= 300 && posY <= 450) {
    collision = true; // Carril vertical izquierdo
  }
  if (posX + diameter / 2 >= 650 && posY >= 250 && posY <= 400) {
    collision = true; // Carril vertical derecho
  }

  // Sección 7
  if (posY + diameter / 2 >= 450 && posX >= 600 && posX <= 750) {
    collision = true; // Carril horizontal superior
  }
  if (posY - diameter / 2 <= 400 && posX >= 650 && posX <= 750) {
    collision = true; // Carril horizontal inferior
  }

  // Bordes del lienzo
  if (posX - diameter / 2 <= 50 || posX + diameter / 2 >= 750) {
    collision = true;
  }
  */
  if (collision) {
    resetPosition();
  }

  // Verifica si la bola toca la línea final (meta)
  if (posX + diameter / 2 >= 750) {
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
