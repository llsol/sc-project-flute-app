import processing.video.*;
import oscP5.*;
import netP5.*;
import processing.sound.*;

OscP5 oscP5;
NetAddress dest;

FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];

void setup() {
  size(512, 360);
  background(255);
  colorMode(RGB, 1.0);
  stroke(0.0);

  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);

  in.start();
  fft.input(in);

  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("127.0.0.1", 9001);  // Cambiar a 9001
}

void draw() {
  background(255);
  fft.analyze(spectrum);

  for (int i = 0; i < bands; i++) {
    line(i, height, i, height - spectrum[i] * height * 5);
  }

  if (frameCount % 2 == 0) {
    sendOsc();
  }
}

void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");

  float rms = 0;
  for (int i = 0; i < spectrum.length; i++) {
    rms += spectrum[i] * spectrum[i];
  }
  rms = sqrt(rms / spectrum.length);

  float dB = 20 * (log(rms) / log(10));
  println("dB Level: " + dB);

  msg.add(dB);
  oscP5.send(msg, dest);
}
