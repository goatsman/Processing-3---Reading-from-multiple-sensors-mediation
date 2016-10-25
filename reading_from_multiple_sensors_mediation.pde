import processing.sound.*; //<>//

import processing.serial.*;

Serial mySerialPort;       // Create object from Serial class
String serialPortData;     // Data received from the serial port

int time;                  // timer for synchronization of sensors
int timeCounter;
int wait = 5000;
int minute = 60000;
int timerGood = 20000;
int timerBad = 10000;
int timerDone = 120000;
int mediationTime = 18000000;
int sensorsValues[] = {0, 0, 0, 0, 0, 0}; //values of sensors
int sensorsMinValues[] = {0,0,0,0,0,0};

int positionsX[] = { 10, 200, 400, 10,200, 400};
int positionsY[] = { 10, 10, 10, 200, 200, 2000};

int colours [] = {50, 70, 100, 150, 200, 250};

SoundFile baseSound;
SoundFile keepMoving;
SoundFile slowDown;
SoundFile closeYourEyes;
SoundFile followCubes;
SoundFile openYourEyes;

int counterGood = 0;
int counterBad = 0;
int counterCorrect = 1;
int followingTwo = 0;


boolean basePlay = false;
boolean closeEyes = false;
boolean finish = false;
boolean follow = false;

float beginX = 20.0;  // Initial x-coordinate
float beginY = 10.0;  // Initial y-coordinate
float endX = 570.0;   // Final x-coordinate
float endY = 320.0;   // Final y-coordinate
float distX;          // X-axis distance to move
float distY;          // Y-axis distance to move
float exponent = 4;   // Determines the curve
float x = 0.0;        // Current x-coordinate
float y = 0.0;        // Current y-coordinate
float step = 0.01;    // Size of each step along the path
float pct = 0.0;      // Percentage traveled (0.0 to 1.0)

void setup() {
  size(600, 800);
  background(255);
  noStroke();
  distX = endX - beginX;
  distY = endY - beginY;
  
  fill(1);
  
  ellipse(150, 150, 20, 20);
  ellipse(170, 200, 20, 20);
  ellipse(200, 170, 20, 20);
  ellipse(300, 300, 20, 20);
  ellipse(350, 270, 20, 20);
  ellipse(370, 320, 20, 20);

  time = millis();
  timeCounter = millis();
  //meditationTime = millis();

  mySerialPort = new Serial(this, Serial.list()[2], 9600);
  mySerialPort.bufferUntil('\n');  
  
  baseSound = new SoundFile(this, "mediation.wav");
  keepMoving = new SoundFile(this, "keep.wav");
  slowDown = new SoundFile(this,"slow.wav");
  closeYourEyes = new SoundFile(this,"close.wav");
  followCubes = new SoundFile(this,"follow.wav");
  openYourEyes = new SoundFile(this,"open.wav");
  
}

void draw() {
  
  //println(sensorsMinValues);
  
  //drawEffects(sensorsValues);

  if (millis() - time >= wait) {
    
    if(!basePlay){
      baseSound.play();
      basePlay = true;
    }
    
    if(counterCorrect == 3){
      if(!closeEyes){
        closeYourEyes.play();
        closeEyes = true;
        follow = true;
        mediationTime = millis();
      }
    }
    
    /*if(counterCorrect > 3 && (counterCorrect % 2) == 0){
      if(!follow){
          keepMoving.play();
      }
    }*/
   
    for (int i = 0; i < 6; i++) {
      
      if (sensorsValues[i] < sensorsMinValues[i]) {
        
        if(millis() - timeCounter >= timerGood && counterGood > 2000){ //<>//
          
          counterCorrect +=1;
          
          if(counterCorrect != 3 && !finish){
            keepMoving.play();
          }
          
          counterGood = 0;
          counterBad = 0;
          timeCounter = millis(); //<>//
          timerGood+=3000;
        
      }
        
          counterGood += 1;
        
      }else{
        
        //followingTwo += 1;
        
        if(millis() - timeCounter >= timerBad && counterBad > 4000 && !closeEyes){
          
          slowDown.play();
          counterBad = 0;
          counterGood = 0;
          timeCounter = millis();
          //counterCorrect -= 1;
          followingTwo = 0;
        
      }
      
        println(counterBad);
        
        counterBad += 1;
        
    }
    
     if (millis() - mediationTime >= timerDone) {
       if(!finish){
          openYourEyes.play();
          finish = true;
         }
      }
    }
  }
}

void serialEvent(Serial mySerialPort) {
  
  String inString = mySerialPort.readStringUntil('\n');
  
   if (inString != null) {
    
    inString = trim(inString); 
    
    int[] serialDataArduino = int(split(inString, ",")); 
    
    //println(serialDataArduino);
    
    if (serialDataArduino.length >=6) {
  
      for (int i = 0; i<6; i++) {
     
        sensorsValues[i] = serialDataArduino[i];
     
     }
     
     //println(sensorsValues);
       
       int j = 0;
       
       for (int i = 6; i<12; i++) {
        sensorsMinValues[j] = serialDataArduino[i];
        j += 1;
    
     }
    
       j = 0;
       
       //println(sensorsMinValues);
   }
  }
}

void drawEffects(int sensorsValues[]){
  fill(0, 2);
  rect(0, 0, width, height);
  pct += step;
  if (pct < 1.0) {
    x = beginX + (pct * distX);
    y = beginY + (pow(pct, exponent) * distY);
  }
  fill(255);
  ellipse(x, y, 20, 20);
  
  pct = 0.0;
  beginX = x;
  beginY = y;
  endX = mouseX;
  endY = mouseY;
  distX = endX - beginX;
  distY = endY - beginY;
}