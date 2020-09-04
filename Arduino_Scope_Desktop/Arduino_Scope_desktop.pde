import controlP5.*;

import processing.serial.*;
//date time tag
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
//dropdown menu
//Creating objects:
Serial port;  // Create object from Serial class
ControlP5 cp5; // you always need the main class

boolean port_selected=false;
int maxnsamp=1200;
int[] values=new int[maxnsamp];
int maxval=4096;
String save_folder="";

//int w_win 800; 
//int h_win=600;
int w_scrn=900;
int h_scrn=600;
int x_scrn=20;
int y_scrn=20;

//trigger status
int x_ts=x_scrn+w_scrn+20;
int y_ts=y_scrn;
int w_ts=50;
int h_ts=20;
int trig_mode=0;
int trig_level=maxval/2;
int trig_offset=100;
boolean doread=false;

//save status
boolean save_mode=false;
int save_fill_color = 255;

//channels
int x_ch=x_ts;
int y_ch=y_ts+4*h_ts;
int w_ch=w_ts;
int h_ch=h_ts;
int maxnchan=6;
int nchan=1;
int fchan=0;
int tchan=maxnchan;
int tmode=0;
//0=off 1=on 2=up 3=down
int chanstat[]={1,0,0,0,0,0};
int nextchan[]={0,0,0,0,0,0};  
color[] chan_color={
  color(255,255,255),
  color(255,  0,  0),
  color(  0,255,  0),
  color(  0,127,255),
  color(255,255,  0),
  color(255,  0,255),
};

//time bar
int x_tb=x_ch;
int y_tb=y_ch+8*h_ch;
int w_tb=w_ch;
int h_tb=h_ch;
int[] tbms    ={ 1, 2, 5, 10, 20, 50,100};
int[] ADCPS   ={16,32,64,128,128,128,128};
int[] skipsamp={ 1, 1, 1,  1,  2,  5, 10};
int ntbval=tbms.length;
int tbval=0;

//nsamp bar
int x_ns=x_tb;
int y_ns=y_tb+(ntbval+2)*h_tb;
int w_ns=w_tb;
int h_ns=h_tb;
int[] ns={1200,600,300};
int nns=ns.length;
int ins=0;
int nsamp=ns[ins];

//vertical bar
int x_vb=x_ns;
int y_vb=y_ns+(nns+2)*h_ch;
int w_vb=w_ns;
int h_vb=h_ns;
int ivb=0;
float Vmax[]={5.0,1.1};
float Vdiv[]={1.0,0.2};

//pulser - everything in units of 1/8th of microsecond
int x_pb=x_scrn+50;
int y_pb=y_scrn+h_scrn+40;
int w_pb=w_scrn-50;
int h_pb=h_ch;
int pls_period[]  ={ 16, 40, 80,160,400,800,1600,4000,8000,16000,40000,10000,20000,50000,12500,25000,62500};
int pls_prescale[]={  1,  1,  1,  1,  1,  1,   1,   1,   1,    1,    1,    8,    8,    8,   64,   64,   64};
int pls_len[][]={
  {  1,  2,  3,   4,   5,   6,    7,   8,     9,   10,   11,   12,   13,   14,   15},
  {  1,  2,  4,   6,   8,  12,   16,   20,   24,   28,   32,   34,   36,   38,   39},
  {  1,  2,  4,   8,  16,  24,   32,   40,   48,   56,   64,   72,   76,   78,   79},
  {  1,  2,  4,   8,  16,  32,   48,   80,  112,  128,  144,  152,  156,  158,  159},
  {  1,  2,  4,   8,  20,  40,   80,  200,  320,  360,  380,  392,  396,  398,  399},
  {  2,  4,  8,  16,  40,  80,  160,  400,  640,  720,  760,  784,  792,  796,  798},
  {  4,  8, 16,  40,  80, 160,  320,  800, 1280, 1440, 1520, 1568, 1584, 1592, 1596},
  { 10, 20, 40,  80, 200, 400,  800, 2000, 3200, 3600, 3800, 3920, 3960, 3980, 3990},
  { 20, 40, 80, 160, 400, 800, 1600, 4000, 6400, 7200, 7600, 7840, 7920, 7960, 7980},
  { 40, 80,160, 400, 800,1600, 3200, 8000,12800,14400,15200,15680,15840,15920,15960},
  {100,200,400, 800,2000,4000, 8000,20000,32000,36000,38000,39200,39600,39800,39900},
  { 25, 50,100, 200, 500,1000, 2000, 5000, 8000, 9000, 9500, 9800, 9900, 9950, 9975},
  { 50,100,200, 500,1000,2000, 5000,10000,16000,18000,19000,19600,19800,19900,19950},
  {125,250,500,1000,2500,5000,10000,25000,40000,45000,48000,49000,49500,49750,49875},
  { 25, 50,125, 250, 500,1250, 2500, 6250,10000,11250,12000,12250,12375,12450,12475},
  { 50,100,250, 500,1000,2500, 5000,12500,20000,22500,24000,24500,24750,24900,24950},
  {125,250,625,1250,2500,6250,12500,31250,50000,56250,60000,61250,61875,62250,62375}};
int pls_np=pls_period.length;
int pls_nl=pls_len[0].length;
int pls_ip=8;
int pls_il=7;

PFont f;
PFont font_menu;

void setup() 
{
  //size(1400,1000);
  size(1000,750);
  background(0);
  drawtb(); //draw the timebar
  drawvb(); //draw the bar for the vertical scale
  drawts(); // draw the trigger status
  drawns(); //draw the nsamp bar
  drawch(); //draw the channel selection
  drawpb(); //pulserbar
  //drawsp();
  //port = new Serial(this, Serial.list()[4], 115200);
  //***************************
  //serial port dropdown menu:
  //***************************
  cp5 = new ControlP5(this);
  font_menu = createFont("ArialMT",10,true);
  cp5.setFont(font_menu);
  // add a dropdownlist at position (100,100)
  DropdownList droplist = cp5.addDropdownList("SerialPortList").setPosition( w_ts, 10).setWidth(200);
  droplist.setBackgroundColor(100);
  //droplist.setSize(80,100);
  //println("list length:",Serial.list().length);
  // add items to the dropdownlist
  for (int i=0; i<Serial.list().length; i++) {
    droplist.addItem(Serial.list()[i], i);
  }
  //FOLDER SELECT
  selectFolder("Select a folder to process:", "folderSelected");
}
  //---
   void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+Serial.list()[int(theEvent.getController().getValue())]+" from "+theEvent.getController());
    port = new Serial(this, Serial.list()[int(theEvent.getController().getValue())], 115200);
    port_selected = true;
  }

}
//Folder select
void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    save_folder = selection.getAbsolutePath();
    println("User selected " + selection.getAbsolutePath());
  }
}
//*******************
//draw serial port label
// void drawsp(){
//   fill(0); stroke(0);
//   rect(0,0,20,10);
//   fill(255); stroke(255);
//   f = createFont("ArialMT",10);
//   textFont(font_menu,10);
//   textAlign(LEFT);
//   text("Port:",0,0);
// }
//draw the pulser bar
void drawpb(){
  fill(0); stroke(0);
  rect(x_pb+w_pb,y_pb,50.0,4*h_pb);
  fill(255); stroke(255);
  f = createFont("ArialMT",16);
  textFont(f,16);
  textAlign(LEFT);
  text("pulser on pin 9",x_pb+2,y_pb-2);
  textAlign(RIGHT);
  text("period",x_pb-2,y_pb+h_tb-2);
  text("freq",x_pb-2,y_pb+2*h_tb-2);
  text("length",x_pb-2,y_pb+3*h_tb-2);
  text("dut cyc",x_pb-2,y_pb+4*h_tb-2);
  textAlign(LEFT);
  text("ms",x_pb+w_pb+2,y_pb+h_tb-2);
  text("kHz",x_pb+w_pb+2,y_pb+2*h_tb-2);
  float t=(pls_period[pls_ip]*pls_prescale[pls_ip])/8000.0;
  if(t>1.0)text("ms",x_pb+w_pb+2,y_pb+3*h_tb-2);
  else text("mus",x_pb+w_pb+2,y_pb+3*h_tb-2);
  textAlign(CENTER);
  for(int i=0; i<pls_np; i++){
    fill(0); stroke(255);
    if(i==pls_ip)fill(128);
    rect(x_pb+i*w_pb/pls_np,y_pb,     w_pb/pls_np,h_pb);
    rect(x_pb+i*w_pb/pls_np,y_pb+h_pb,w_pb/pls_np,h_pb);
    fill(255);
    float period=(pls_period[i]*pls_prescale[i])/8000.0;
    text(nf(period,0,0),x_pb+(i+0.5)*w_pb/pls_np,y_pb+h_pb-2);
    float freq=1.0/period;
    text(nf(freq,0,0),x_pb+(i+0.5)*w_pb/pls_np,y_pb+2*h_pb-2);
  } 
  for(int i=0; i<pls_nl; i++){
    fill(0); stroke(255);
    if(i==pls_il)fill(128);
    rect(x_pb+i*w_pb/pls_nl,y_pb+2*h_pb,w_pb/pls_nl,h_pb);
    rect(x_pb+i*w_pb/pls_nl,y_pb+3*h_pb,w_pb/pls_nl,h_pb);
    fill(255); stroke(255);
    float len=(pls_len[pls_ip][i]*pls_prescale[pls_ip])/8000.0;
    if (t<=1.0)len*=1e3;
    text(nf(len,0,0),x_pb+(i+0.5)*w_pb/pls_nl,y_pb+3*h_pb-2);
    float dut=1.0*pls_len[pls_ip][i]/pls_period[pls_ip];
    text(nf(dut,0,0),x_pb+(i+0.5)*w_pb/pls_nl,y_pb+4*h_pb-2);
  } 
}

//draw the timebar
void drawtb(){
  fill(255); stroke(255);
  //f = createFont("ArialMT",16);
    f = createFont("Dialog",12);
  textFont(f,16);
  textAlign(CENTER);
  text("ms/div",x_tb+w_tb/2,y_tb-2);
  for(int i=0; i<ntbval; i++){
    fill(0); stroke(255);
    if(i==tbval)fill(128);
    rect(x_tb,y_tb+i*h_tb,w_tb,h_tb);
    fill(255); stroke(255);
    text(tbms[i],x_tb+0.5*w_tb,y_tb+(i+1)*h_tb-2);
  } 
}

//draw the nsamp bar
void drawns(){
  fill(255); stroke(255);
  f = createFont("ArialMT",16);
  textFont(f,16);
  textAlign(CENTER);
  text("nsamp",x_ns+w_ns/2,y_ns-2);
  for(int i=0; i<nns; i++){
    fill(0); stroke(255);
    if(i==ins)fill(128);
    rect(x_ns,y_ns+i*h_ns,w_ns,h_ns);
    fill(255); stroke(255);
    text(ns[i],x_ns+0.5*w_ns,y_ns+(i+1)*h_ns-2);
  } 
}


//draw the bar for the vertical scale
void drawvb(){
  fill(255); stroke(255);
  f = createFont("ArialMT",16);
  textFont(f,16);
  textAlign(CENTER);
  text("V/div",x_vb+w_vb/2,y_vb-2);
  fill(0); stroke(255);
  if(ivb==0)fill(128);
  rect(x_vb,y_vb+0*h_vb,w_vb,h_vb);
  fill(255); stroke(255);
  text("1.0",x_vb+0.5*w_vb,y_vb+1*h_tb-2); 
  fill(0); stroke(255);
  if(ivb==1)fill(128);
  rect(x_vb,y_vb+1*h_vb,w_vb,h_vb);
  fill(255); stroke(255);
  text("0.2",x_vb+0.5*w_vb,y_vb+2*h_tb-2); 
}

//************************
// draw the trigger status
//************************
void drawts(){
  fill(255); stroke(255);
  f = createFont("ArialMT",16);
  textFont(f,16);
  textAlign(CENTER);
  text("trigger",x_ts+w_ts/2,y_ts-2);
  fill(0); stroke(255);
  if(trig_mode==0)fill(128);
  rect(x_ts,y_ts,w_ts,h_ts);
  fill(255); stroke(255);
  text("run",x_ts+0.5*w_ts,y_ts+h_ts-3);
  fill(0); stroke(255);
  if(trig_mode==1)fill(128);
  rect(x_ts,y_ts+h_ts,w_ts,h_ts);
  fill(255); stroke(255);
  text("shot",x_ts+0.5*w_ts,y_ts+2*h_ts-3);
   //save button
  fill(0); stroke(255);
  rect(x_ts,y_ts+2*h_ts,w_ts,h_ts);
  fill(save_fill_color);
  stroke(255);
  text("save",x_ts+0.5*w_ts,y_ts+3*h_ts-3);
}

//draw the channel selection
void drawch(){
  fill(255); stroke(255);
  f = createFont("ArialMT",16);
  textFont(f,16);
  textAlign(CENTER);
  text("channels",x_ch+w_ch/2,y_ch-2);
  for (int ichan=0; ichan<maxnchan; ichan++){
    fill(0); stroke(255);
    if (chanstat[ichan]>0)fill(128);
    rect(x_ch,y_ch+ichan*h_ch,w_ch/3,h_ch);
    fill(chan_color[ichan]); stroke(255);
    text(ichan,x_ch+w_ch/6.0,y_ch+(ichan+1)*h_ch-3);
    fill(0); stroke(255);
    if (chanstat[ichan]==2)fill(128);
    rect(x_ch+w_ch/3.0,y_ch+ichan*h_ch,w_ch/3,h_ch);
    fill(255); stroke(chan_color[ichan]);
    line(x_ch+w_ch*(1.0/2.0),y_ch+(ichan)*h_ch+3,x_ch+w_ch*(1.0/2.0),y_ch+(ichan+1)*h_ch-3);
    line(x_ch+w_ch*(1.0/2.0),y_ch+(ichan)*h_ch+3,x_ch+w_ch*(1.0/2.0)+4,y_ch+(ichan)*h_ch+3);
    line(x_ch+w_ch*(1.0/2.0),y_ch+(ichan+1)*h_ch-3,x_ch+w_ch*(1.0/2.0)-4,y_ch+(ichan+1)*h_ch-3);
    fill(0); stroke(255);
    if (chanstat[ichan]==3)fill(128);
    rect(x_ch+w_ch/1.5,y_ch+ichan*h_ch,w_ch/3,h_ch);
    fill(255); stroke(chan_color[ichan]);
    line(x_ch+w_ch*(5.0/6.0),y_ch+(ichan)*h_ch+3,x_ch+w_ch*(5.0/6.0),y_ch+(ichan+1)*h_ch-3);
    line(x_ch+w_ch*(5.0/6.0),y_ch+(ichan)*h_ch+3,x_ch+w_ch*(5.0/6.0)-4,y_ch+(ichan)*h_ch+3);
    line(x_ch+w_ch*(5.0/6.0),y_ch+(ichan+1)*h_ch-3,x_ch+w_ch*(5.0/6.0)+4,y_ch+(ichan+1)*h_ch-3);

  }
}

void drawscrn(){
  //trigger level
  fill(0); stroke(0);
  rect(x_scrn-10,y_scrn,10,h_scrn);
  fill(255); stroke(255);
  float y_tl=y_scrn+h_scrn-trig_level/(1.0*maxval)*h_scrn;
  line(x_scrn-10,y_tl,x_scrn,y_tl);
  line(x_scrn-5,y_tl-4,x_scrn,y_tl);
  line(x_scrn-5,y_tl+4,x_scrn,y_tl);

  //trigger offset
  fill(0); stroke(0);
  rect(x_scrn,y_scrn-10,w_scrn,10);
  fill(255); stroke(255);
  float x_to=x_scrn+w_scrn*(1.0*trig_offset)/(1.0*nsamp);
  line(x_to,y_scrn-10,x_to,y_scrn);
  line(x_to-4,y_scrn-4,x_to,y_scrn);
  line(x_to+4,y_scrn-4,x_to,y_scrn);
 
  //outline
  fill(0); stroke(255);
  rect(x_scrn,y_scrn,w_scrn,h_scrn);

  //grid
  int ndivy=int(Vmax[ivb]/Vdiv[ivb]);
  int nsdivy=5;
  for(int i=0; i<=ndivy; i++){
    float y=y_scrn+h_scrn-i*h_scrn*Vdiv[ivb]/Vmax[ivb];
    fill(0); stroke(128);
    line(x_scrn,y,x_scrn+w_scrn,y);
    for(int is=1; is<nsdivy; is++){
      y-=h_scrn*(Vdiv[ivb]/nsdivy)/Vmax[ivb];
      fill(0); stroke(32);
      if(y>y_scrn)line(x_scrn,y,x_scrn+w_scrn,y);
    }    
  }
  float fsamp=16e6/(13*ADCPS[tbval]*skipsamp[tbval]);
  float xdivdist=1e-3*tbms[tbval]*fsamp*((1.0*w_scrn)/(1.0*nsamp));
  int ndivx=int(w_scrn/xdivdist);
  int nsdivx=2;
  if (nsamp==600 && tbms[tbval]==  1.0)nsdivx=5;
  if (nsamp==600 && tbms[tbval]==  2.0)nsdivx=4;
  if (nsamp==600 && tbms[tbval]==  5.0)nsdivx=5;
  if (nsamp==600 && tbms[tbval]== 10.0)nsdivx=5;
  if (nsamp==600 && tbms[tbval]== 20.0)nsdivx=4;
  if (nsamp==600 && tbms[tbval]== 50.0)nsdivx=5;
  if (nsamp==600 && tbms[tbval]==100.0)nsdivx=5;
  if (nsamp==300)nsdivx=10;
  for(int i=0; i<=ndivx; i++){
    fill(0); stroke(128);
    float x=x_scrn+i*xdivdist;
    line(x,y_scrn,x,y_scrn+h_scrn);
    for(int is=1; is<nsdivx; is++){
      x+=xdivdist/nsdivx;
      fill(0); stroke(32);
      if(x<x_scrn+w_scrn)line(x,y_scrn,x,y_scrn+h_scrn);
    }    
  }
}

void getdata(){
  //send command to arduino to readout data
  port.write(255); 
  port.write(nsamp/0x100);
  port.write(nsamp%0x100);
  for (int i=0; i<maxnchan; i++)port.write(chanstat[i]);
  for (int i=0; i<maxnchan; i++)port.write(nextchan[i]);
  port.write(fchan);
  port.write(nchan);
  port.write(tchan);
  port.write(tmode);
  port.write(ADCPS[tbval]);
  port.write(skipsamp[tbval]);
  port.write(ivb);
  port.write(trig_level/16);
  port.write(trig_offset/0x100);
  port.write(trig_offset%0x100);
  if(pls_prescale[pls_ip]== 1)port.write(1);
  if(pls_prescale[pls_ip]== 8)port.write(2);
  if(pls_prescale[pls_ip]==64)port.write(3);
  port.write(pls_period[pls_ip]/0x100);
  port.write(pls_period[pls_ip]%0x100);
  port.write(pls_len[pls_ip][pls_il]/0x100);
  port.write(pls_len[pls_ip][pls_il]%0x100);

  //estimate the response time as the sum of the sampling time plus the time to send the data
  float sampletime=nsamp*(13*ADCPS[tbval]*skipsamp[tbval])/16e3;
  float sendtime=16.0*nsamp/115.2;
  //println(sampletime,sendtime);

  delay(int((2.0*sampletime+1.1*sendtime)));
  //println(port.available());
  while(port.available()>=2*nsamp+1){
    if(port.read()==255){
      for(int isamp=0; isamp<nsamp; isamp++){
        int hsb=port.read();
        int lsb=port.read();
        values[isamp]=hsb*64+(lsb&0xFF);
      }
      doread=false;
    }
  }
}


void drawtraces(){
  //draw the traces
  for (int ichan=0; ichan<maxnchan; ichan++){
    if (chanstat[ichan]==0) continue;
    fill(255); stroke(chan_color[ichan]);
    float xprev=0.0; 
    float yprev=0.0;
    int i=fchan;
    for(int isamp=0; isamp<nsamp; isamp++){
      if(i==ichan){
        float x=x_scrn+isamp*(w_scrn/(1.0*nsamp));
        float y=y_scrn+h_scrn-values[isamp]*(h_scrn/(1.0*maxval));
        if(isamp>=nchan) line(xprev,yprev,x,y);
        xprev=x;
        yprev=y;
      }
      i=nextchan[i];
    }
  }   
}

void draw()
{
  if(port_selected){
  drawscrn();
  if(trig_mode==0 || doread)getdata();
  drawtraces(); 
  save_mode=false;
  }
}

void save_data()
{
  //current date timetag
  LocalDate date = LocalDate.now();
  LocalTime time = LocalTime.now();
  LocalDateTime dateTime2 = LocalDateTime.of(date, time.withNano(0));
  println(dateTime2);
  //
  Table table;
  table = new Table();
  table.addColumn("time(s)");
  //creating voltage channels
  for (int ichan=0; ichan<maxnchan; ichan++){
    if(chanstat[ichan]>0){
     table.addColumn("voltage_"+str(ichan));
    }
  }
  //creating x-valued rows
  for(int isamp=0; isamp<nsamp/nchan; isamp++){
    float x = isamp/(1.0*nsamp);
    TableRow newRow = table.addRow();
    newRow.setFloat("time(s)",x);
  }
  //attributing y-values for enabled channels
  int ichan0 =0; 
  for (int ichan=0; ichan<maxnchan; ichan++){
    println("chanstat,",chanstat[ichan]);
    if(chanstat[ichan]>0){
      println(str(ichan));
      for(int isamp=0; isamp<nsamp/nchan; isamp++){
          //float y = values[ichan+isamp*nchan]/(1.0*maxval);
          float y = values[ichan0+isamp*nchan];
          table.setFloat(isamp,"voltage_"+str(ichan), y);
      }
      ichan0+=1;
    }
  }
  //String timetag = str(dateTime2);
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
  String formattedDateTime = dateTime2.format(formatter);
  //timetag.replace(':','-');
  println(save_folder+File.separator+"canais_"+formattedDateTime+".csv");
  saveTable(table, save_folder+File.separator+"canais_"+formattedDateTime+".csv");
  //TableRow row = table.addRow();

////Set the values of all columns in that row.
}

//called everytime a mouse is pressed
void mousePressed(){  //check for mouse clicks

  //pulser bar - period/frequency selection
  if(mouseX>x_pb && mouseX<x_tb+w_pb && mouseY>y_pb && mouseY<y_pb+4*h_pb){
    if(mouseY<y_pb+2*h_pb) pls_ip=int((mouseX-x_pb)/(w_pb/pls_np));
    if(mouseY>y_pb+2*h_pb) pls_il=int((mouseX-x_pb)/(w_pb/pls_nl));
    drawpb();
  }

  //timebar
  if(mouseX>x_tb && mouseX<x_tb+w_tb && mouseY>y_tb && mouseY<y_tb+ntbval*h_tb){
    tbval=int((mouseY-y_tb)/h_tb);
    drawtb();
  }
  
  //nsamp bar
  if(mouseX>x_ns && mouseX<x_ns+w_ns && mouseY>y_ns && mouseY<y_ns+nns*h_ns){
    ins=int((mouseY-y_ns)/h_ns);
    nsamp=ns[ins];
    if (trig_offset>=nsamp)trig_offset=nsamp-1;
    drawns();
  }
  
  //vertical scale bar
  if(mouseX>x_vb && mouseX<x_vb+w_vb && mouseY>y_vb && mouseY<y_vb+2*h_vb){
    ivb=int((mouseY-y_vb)/h_vb);
    drawvb();
  }

  //trigger mode
  if(mouseX>x_ts && mouseX<x_ts+w_ts && mouseY>y_ts && mouseY<y_ts+h_ts){
    trig_mode=0;
    drawts();

  }
  if(mouseX>x_ts && mouseX<x_ts+w_ts && mouseY>y_ts+h_ts && mouseY<y_ts+2*h_ts){
    trig_mode=1;
    drawts();
    doread=true;
  }
  
  
  //trigger level
  if(mouseX>x_scrn-10 && mouseX<x_scrn && mouseY>y_scrn && mouseY<y_scrn+h_scrn){
    //trig_level=(mouseY-y_scrn)*255/h_scrn;
    trig_level=(y_scrn+h_scrn-mouseY)*maxval/h_scrn;
  }

  //trigger offset
  if(mouseX>x_scrn && mouseX<x_scrn+w_scrn && mouseY<y_scrn && mouseY>y_scrn-10){
    trig_offset=(int)((1.0*mouseX-1.0*x_scrn)*(1.0*nsamp)/(1.0*w_scrn));
  }
  //save data
  if(mouseX>x_ts && mouseX<x_ts+w_ts && mouseY>y_ts+2*h_ts && mouseY<y_ts+3*h_ts){
    trig_mode=0;
    save_mode=!save_mode;
    
    save_fill_color =0;
    drawts();
    //doread=true;
    save_data();
    delay(500);
    save_fill_color =255;
    drawts();

  } 
  //channel and trigger selection
  if(mouseX>x_ch && mouseX<x_ch+w_ch && mouseY>y_ch && mouseY<y_ch+maxnchan*h_ch){
    int ichan=int((mouseY-y_ch)/h_ch);
    int ipos=int(3*(mouseX-x_ch)/w_ch);
    if (ipos==0){
      if (chanstat[ichan]==0)chanstat[ichan]=1;
      else if (chanstat[ichan]>=1 && nchan>1)chanstat[ichan]=0;
    }
    if (ipos==1 || ipos==2){
      if(chanstat[ichan]==ipos+1)chanstat[ichan]=1;
      else{
        for(int i=0; i<maxnchan; i++)chanstat[i]=min(chanstat[i],1);
        chanstat[ichan]=ipos+1;
      }
    }

    //calculate some handy numbers
    fchan=0; for(int i=maxnchan-1; i>=0; i--)if(chanstat[i]>0)fchan=i;
    nchan=0; for(int i=0; i<maxnchan; i++)if(chanstat[i]>0)nchan++;
    tchan=maxnchan; for(int i=0; i<maxnchan; i++)if(chanstat[i]>1)tchan=i;
    tmode=0; for(int i=0; i<maxnchan; i++)if(chanstat[i]>1)tmode=chanstat[i];

    //build the nextchan array
    for(int i=0; i<maxnchan; i++){
      for(int j=1; j<=maxnchan; j++){
        int i2=(i+j)%maxnchan;
        if(chanstat[i2]>0){
          nextchan[i]=i2;
          break;
        }
      }
    }
    drawch();
   
  }

}
