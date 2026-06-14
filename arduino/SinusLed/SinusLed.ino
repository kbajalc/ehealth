// Arduino UNO — Sinusoidal blink delay on built-in LED (pin 13)

#include <math.h>

const int LED_PIN  = 13;
const int MIN_DELAY = 50;   // fastest blink (ms)
const int MAX_DELAY = 150;  // slowest blink (ms)

void loop() {
  for (int i = 0; i < 100; i++) {
    float angle = (2.0 * PI * i) / 100.0;

    // Remap sin() from -1..+1 to MIN_DELAY..MAX_DELAY
    int blinkDelay = (int)(((sin(angle) + 1.0) / 2.0) * (MAX_DELAY - MIN_DELAY) + MIN_DELAY);

    digitalWrite(LED_PIN, HIGH);
    delay(blinkDelay);
    digitalWrite(LED_PIN, LOW);
    delay(blinkDelay);
  }
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
}