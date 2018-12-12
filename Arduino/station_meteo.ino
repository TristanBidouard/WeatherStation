#include <SoftwareSerial.h>

//#define MODE "RECEIVER"
#define MODE "TRANSMITTER"
#define RX_PORT 2
#define TX_PORT 3
#define BAUDRATE 9600
#define TAB 4

typedef struct data{
  short ligthness;    
  short humidity;    
  short temperature;
  short pressure;
} data;

typedef union {
  short tab[TAB];
  data struc;
} struct2tab;

struct2tab union_data;

byte data_from_xbee;

void setup() {

  Serial.begin(BAUDRATE);
  delay(100);
  Serial.println("ARDUINO->PC : OK");

  //MODE
  Serial.println(MODE);

  //INIT
  union_data.struc.lightness = 1;
  union_data.struc.humidity = 2;
  union_data.data.temperature = 3;
  union_data.struc.pressure = 4;
}

void loop() {

  if(MODE == "RECEIVER"){
    
    if (Serial.available()){
      data_from_xbee = Serial.read();
      Serial.print(data_from_xbee);
    }
    
  }else if(MODE == "TRANSMITTER"){

    send_data(union_data);
    delay(1000);
    
  }
}

void send_data(struct2tab data){
  int i = 0;
  while(i < sizeof(data)){
    Serial.print(data.tab[i]);
    i++;
  }
}


