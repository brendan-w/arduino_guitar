#include "dsp.h"
#include "math.h"

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif
#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif


#define MEM_LENGTH 1000
#define THRESH 100


int mem[MEM_LENGTH];


int sound;
int s;
int temp_sound;
int d;
float f;

int mode;

void setup() {
  
  setupIO(); //configures PWM to go faster
  
  //sbi(ADCSRA,ADPS2);
  //cbi(ADCSRA,ADPS1);
  //cbi(ADCSRA,ADPS0);
  
  mode = 1;

  //temp_sound = analogRead(left); //flush
  //temp_sound = analogRead(left); //get actual value
}

void loop() {
    setMode();
  
    //read signal (signal is in first ten bits)
    //values are 0-1024, should be centered at 512
    sound = analogRead(left);
    sound -= 512;
    
    switch(mode)
    {
      case 1: //Fuzz Box
        sound *= 8;
        if(sound > THRESH) { sound = THRESH;}
        else if(sound < -THRESH) { sound = -THRESH; }
        break;
      case 2: //Slap-Back Delay
        d = d % MEM_LENGTH;
        
        temp_sound = mem[d];
        mem[d] = sound;
        temp_sound /= 2;
        sound /= 2 ;
        sound += temp_sound;
        
        d++;
        break;
      case 3: //Reverb
        d = d % MEM_LENGTH;
        
        temp_sound = mem[d];
        mem[d] = sound;
        temp_sound /=2 ;
        sound /=2 ;
        sound += temp_sound;
        
        //mem[d] /= 2;
        //mem[d] += (sound >> 1);
        mem[d] += (sound / 2);
        
        d++;
        break;
      case 4:
        if(f > 1) { f = 0.25; }
        sound *= f;
        f += 0.0006;
        break;
    }
    
    //output the processed sound
    sound += 512;
    output(left, sound);
}

void setMode()
{
  int m = analogRead(A5);
  if(m < 204) { mode = 0; }
  else if(m < 408) { mode = 1; }
  else if(m < 614) { mode = 2; }
  else if(m < 820) { mode = 3; }
  else { mode = 4; }
}
