//DAQ for oscilloscope, to be used together with corresponding processing application

//global variables
const unsigned int maxnsamp=1200;
byte y[maxnsamp];
byte lsb[maxnsamp/4];
const byte maxnchan=6;
byte chanstat[maxnchan]={1,0,0,0,0,0};
byte nextchan[maxnchan]={0,0,0,0,0,0};
byte ADMUXBASE=B01100000;

void setup() {
  //setup serial communication at the highest possible rate
  Serial.begin(115200); 

  //setup TIMER1 for 1kHz 50% duty cycle pulse on pin D9
  pinMode(9,OUTPUT);
  TCCR1A=B10000000;
  TCCR1B=B00010001;
  OCR1A =8000;
  ICR1  =16000;
  
  //Set up the analog input and the ADC, prescaler is important to increase samlping rate.
  DDRC=B00000000; // all analog channels on input
  ADCSRA=B11110100; // prescale 16 -> 13 mus per sample, auto trigger
  ADCSRB=B00000000; // freerun
  ADMUX =ADMUXBASE; // Vcc ref, left-align, ch0
}

//byte a=0;
void loop() {
  int nsamp;
  byte fchan;
  byte nchan;
  byte tchan;
  byte tmode;
  byte ivb;
  byte adc_ps;
  byte skipsamp;
  byte trig_level;
  int trig_offset;
  unsigned int pls_ps;
  unsigned int pls_len;
  unsigned int pls_per;
;  
  bool gotcommand=false;
  bool corrupt=false;
  if(Serial.available()>=30){
    if(Serial.read()==255){
      nsamp=Serial.read()*0x100+Serial.read();
      if (nsamp!=1200 and nsamp!=600 and nsamp!=300)corrupt=true;
      for(byte ichan=0; ichan<maxnchan; ichan++)chanstat[ichan]=Serial.read();
      for(byte ichan=0; ichan<maxnchan; ichan++)if(chanstat[ichan]>3)corrupt=true;
      for(byte ichan=0; ichan<maxnchan; ichan++)nextchan[ichan]=Serial.read();
      for(byte ichan=0; ichan<maxnchan; ichan++)if(nextchan[ichan]>=maxnchan)corrupt=true;        
      fchan=Serial.read();
      if(fchan>=maxnchan)corrupt=true;
      nchan=Serial.read();
      if(nchan>maxnchan)corrupt=true;
      tchan=Serial.read();
      if(tchan>maxnchan)corrupt=true;
      tmode=Serial.read();
      if(tmode>3)corrupt=true;
      adc_ps=Serial.read();
      if(adc_ps!=16 and adc_ps!=32 and adc_ps!=64 and adc_ps!=128)corrupt=true;
      skipsamp=Serial.read();
      if(skipsamp!=1 and skipsamp!=2 and skipsamp!=5 and skipsamp!=10)corrupt=true;
      ivb=Serial.read();
      if(ivb>1)corrupt=true;
      trig_level=Serial.read();
      trig_offset=Serial.read()*0x100+Serial.read();
      if(trig_offset>nsamp)corrupt=true;
      pls_ps=Serial.read();
      if(pls_ps<1 or pls_ps>3)corrupt=true;
      pls_per=Serial.read()*0x100+Serial.read();
      pls_len=Serial.read()*0x100+Serial.read();
      gotcommand=true;
    }
  }
  if(corrupt){
    digitalWrite(13,HIGH); delay(100); digitalWrite(13,LOW);  
  }
  
  if(gotcommand and not corrupt){
    TCCR1B=B00010000+pls_ps;
    ICR1  =pls_per;           
    OCR1A =pls_len;
    if(adc_ps== 16)ADCSRA=B11110100;
    if(adc_ps== 32)ADCSRA=B11110101;
    if(adc_ps== 64)ADCSRA=B11110110;
    if(adc_ps==128)ADCSRA=B11110111;
    if (ivb==0)ADMUXBASE=B01100000;
    if (ivb==1)ADMUXBASE=B10100000;

    int isamp=0;
    //byte iskip=0;
    byte ichan=fchan;
  
    ADMUX =ADMUXBASE+ichan; // select first channel
    while ((ADCSRA &(1<<ADIF))==0); //wait till adc conversion is ready
    byte yprev=ADCH; 
    ADCSRA |= (1<<ADIF); //clear(!) the Interrupt flag bit

    int istop=-1;
    if (tmode==0) istop=0; //no trigger means trigger on first sample
    noInterrupts();
    while (true){
      //ADMUX =ADMUXBASE+ichan; //set the channel for the next reading
      for(byte iskip=0; iskip<skipsamp; iskip++){
        if(iskip==skipsamp-1)ADMUX =ADMUXBASE+nextchan[ichan]; //set the channel for the next reading  
        while ((ADCSRA &(1<<ADIF))==0); //wait till adc conversion is ready
        ADCSRA |= (1<<ADIF);        
      } 
      byte y_lsb=ADCL;
      byte ynew=ADCH; 
      y[isamp]=ynew;
      lsb[isamp>>2]=(lsb[isamp>>2]>>2)+y_lsb;
            
      //check for trigger
      if(isamp>trig_offset and istop<0 and ichan==tchan){
        if(tmode==2){ // up-edge
          if(ynew>trig_level and yprev<=trig_level){
            istop=isamp-trig_offset;
            if(istop<0)istop+=nsamp;
          }
        }
        if(tmode==3){ // down-edge
          if(ynew<trig_level and yprev>=trig_level){   
            istop=isamp-trig_offset;
            if(istop<0)istop+=nsamp;
          }
        }
      }
      if (ichan==tchan) yprev=ynew;
    
      isamp++; 
      if(isamp>=nsamp)isamp=0;
      ichan=nextchan[ichan];
      
      //stop the loop when reached the end
      if(isamp==istop)break;

      //stop to check for commands after full cycle without trigger
      if(istop<0 and isamp==0)break;
    }
    interrupts();
  
    //send the data to the PC
    if(istop>=0){
      //round off istop to the nearest multiple of nchan
      istop=((istop+nchan/2)/nchan)*nchan;
      Serial.write(255);
      for (int isamp=0; isamp<nsamp; isamp++){
        //split in two 6-bit numbers
        int isamp2=(isamp+istop)%nsamp;
        byte hi=y[isamp2]>>2;
        byte lo=(y[isamp2]&B00000011)<<4;
        lo+=(lsb[isamp2>>2]>>(isamp2&B00000011))&B00000011;
        Serial.write(hi);
        Serial.write(lo);
      }
    }

  }  
  
}
