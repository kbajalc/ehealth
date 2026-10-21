#include <eHealth.h>

extern volatile unsigned long timer0_overflow_count;

float voltage;
float conductance;
float resistance;

int window;
int ticks;
int count;

unsigned long time;
byte serialByte;

void setup() {
  Serial.begin(9600);

  voltage = 0;
  conductance = 0;
  resistance = 0;

  window = 10;
  ticks = 0;
  count = 0;
}

void loop() {
  // V = analogRead * 5.0 / 1023
  float vol = eHealth.getSkinConductanceVoltage();

  // G = 2*(V − 0.5) / 100000; G * 1000000
  // µS (microsiemens)
  float con = eHealth.getSkinConductance();

  // R = 1/G Ω (ohms)
  float res = eHealth.getSkinResistance();

  // Use the timer0 => 1 tick every 4 us
  time=(timer0_overflow_count << 8) + TCNT0;
  // Microseconds conversion.
  time=time*4;

  voltage += vol;
  if (con != -1 && res != -1) {
    conductance += con;
    resistance += res;
    count++;
  }

  ticks++;
  if (ticks < window) return;

  if (count == 0) count = 1;

  voltage /= ticks;
  voltage -= 0.5;
  conductance /= count;
  resistance /= count;

  // Print in a file for simulation
  Serial.print(time);
  Serial.print(",");
  Serial.print(voltage*10, 5);
  Serial.print(",");
  Serial.print(conductance, 5);
  Serial.print(",");
  Serial.println(resistance/100000, 5);
  
  ticks = 0;
  count = 0;
  voltage = 0;
  conductance = 0;
  resistance = 0;
}

