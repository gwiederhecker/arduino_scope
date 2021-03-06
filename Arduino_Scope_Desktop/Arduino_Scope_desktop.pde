import processing.serial.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

import static javax.swing.JOptionPane.*;
//dropdown menu
//Creating objects:
Serial port = null;  // Create object from Serial class
//ControlP5 cp5; // you always need the main class

//---cross-marker toolip variables
int mouseX0;
int mouseY0;
String theTooltipString;
String theTooltipString2;
String theTooltipString3;
//-------
boolean port_selected=false;
int maxnsamp=1200;
int[] values=new int[maxnsamp];
int maxval=4096;
String save_folder;
boolean folder_selected=false;

//int w_win 800; 
//int h_win=600;
int h_knobs = 0; //knobs for controlling df offset and channel gain
int w_scrn=700;
//int h_scrn=480;
int h_scrn=480-h_knobs;
int x_scrn=20;
int y_scrn=20;
int fsize= 12;
float VmaxArduino = 5.0;
//trigger status
int x_ts=x_scrn+w_scrn+20;
int y_ts=y_scrn;
//int w_ts=50;
//int h_ts=20;
int w_ts=40;
int h_ts=15;
int trig_mode=0;
int trig_level=maxval/2;
int trig_offset=100;
boolean doread=false;

//save status
boolean save_mode=false;
int save_fill_color = 255;
color this_color=color(255,255,255);
//channels
int[] dc_level={0,0,0,0,0,0}; //for future dc_offset
float[] gain_level={1,1,1,1,1,1}; //for future channel gain
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
int chanstat[]={1, 0, 0, 0, 0, 0};
int nextchan[]={0, 0, 0, 0, 0, 0};  
color[] chan_color={
  color(255, 255, 255), 
  color(255, 0, 0), 
  color(  0, 255, 0), 
  color(  0, 127, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
};

//time bar
int x_tb=x_ch;
int y_tb=y_ch+8*h_ch;
int w_tb=w_ch;
int h_tb=h_ch;
int[] tbms    ={1, 2, 5, 10, 20, 50, 100};
int[] ADCPS   ={16, 32, 64, 128, 128, 128, 128};
int[] skipsamp={ 1, 1, 1, 1, 2, 5, 10};
int ntbval=tbms.length;
int tbval=0;

//nsamp bar
int x_ns=x_tb;
int y_ns=y_tb+(ntbval+2)*h_tb;
int w_ns=w_tb;
int h_ns=h_tb;
int h_usb =70;//usb port option vertical offset
int[] ns={1200, 600, 300};
int nns=ns.length;
int ins=0;
int nsamp=ns[ins];

//vertical bar
int x_vb=x_ns;
int y_vb=y_ns+(nns+2)*h_ch;
int w_vb=w_ns;
int h_vb=h_ns;
int ivb=0;
float Vmax[]={5.0, 1.1};
float Vdiv[]={1.0, 0.2};

//pulser - everything in units of 1/8th of microsecond
int x_pb=x_scrn+50;
//int y_pb=y_scrn+h_scrn+40;
//int y_pb=y_scrn+h_scrn+20;
int y_pb=y_scrn+h_scrn+20+h_knobs;
int w_pb=w_scrn-50;
int h_pb=h_ch;
int pls_period[]  ={ 16, 40, 80, 160, 400, 800, 1600, 4000, 8000, 16000, 40000, 10000, 20000, 50000, 12500, 25000, 62500};
int pls_prescale[]={  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 8, 8, 8, 64, 64, 64};
int pls_len[][]={
  {  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}, 
  {  1, 2, 4, 6, 8, 12, 16, 20, 24, 28, 32, 34, 36, 38, 39}, 
  {  1, 2, 4, 8, 16, 24, 32, 40, 48, 56, 64, 72, 76, 78, 79}, 
  {  1, 2, 4, 8, 16, 32, 48, 80, 112, 128, 144, 152, 156, 158, 159}, 
  {  1, 2, 4, 8, 20, 40, 80, 200, 320, 360, 380, 392, 396, 398, 399}, 
  {  2, 4, 8, 16, 40, 80, 160, 400, 640, 720, 760, 784, 792, 796, 798}, 
  {  4, 8, 16, 40, 80, 160, 320, 800, 1280, 1440, 1520, 1568, 1584, 1592, 1596}, 
  { 10, 20, 40, 80, 200, 400, 800, 2000, 3200, 3600, 3800, 3920, 3960, 3980, 3990}, 
  { 20, 40, 80, 160, 400, 800, 1600, 4000, 6400, 7200, 7600, 7840, 7920, 7960, 7980}, 
  { 40, 80, 160, 400, 800, 1600, 3200, 8000, 12800, 14400, 15200, 15680, 15840, 15920, 15960}, 
  {100, 200, 400, 800, 2000, 4000, 8000, 20000, 32000, 36000, 38000, 39200, 39600, 39800, 39900}, 
  { 25, 50, 100, 200, 500, 1000, 2000, 5000, 8000, 9000, 9500, 9800, 9900, 9950, 9975}, 
  { 50, 100, 200, 500, 1000, 2000, 5000, 10000, 16000, 18000, 19000, 19600, 19800, 19900, 19950}, 
  {125, 250, 500, 1000, 2500, 5000, 10000, 25000, 40000, 45000, 48000, 49000, 49500, 49750, 49875}, 
  { 25, 50, 125, 250, 500, 1250, 2500, 6250, 10000, 11250, 12000, 12250, 12375, 12450, 12475}, 
  { 50, 100, 250, 500, 1000, 2500, 5000, 12500, 20000, 22500, 24000, 24500, 24750, 24900, 24950}, 
  {125, 250, 625, 1250, 2500, 6250, 12500, 31250, 50000, 56250, 60000, 61250, 61875, 62250, 62375}};
int pls_np=pls_period.length;
int pls_nl=pls_len[0].length;
int pls_ip=8;
int pls_il=7;

PFont f;
PFont font_menu;
String portname = null;

int newWidth, newHeight;
int currWidth, currHeight;

//****************************
//Open serial port function
void openSerialPort()
{
  if (portname == null) return;
  if (port != null) port.stop();
  port = new Serial(this, portname, 115200);
  //port.bufferUntil('\n');
}
//****************************
//Select serial port   function
void selectSerialPort()
{
  try {
    String input_port = (String) showInputDialog(null, "Serial port", 
    "Select Arduino Serial Port ", QUESTION_MESSAGE, null, // Use
    // default
    // icon
    Serial.list(), // Array of choices
    Serial.list()[0]); // Initial choice
    if (input_port!= null) {
    portname = input_port;
    openSerialPort();
    port_selected = true;
  }
  //run a bit of code
} catch (Exception e) {
   javax.swing.JOptionPane.showMessageDialog(null, "No serial ports connected! Plug your Arduino to the USB port. " + e);
} 


}
void draw_interface()
{
  drawtb(); //draw the timebar
  drawvb(); //draw the bar for the vertical scale
  drawts(); // draw the trigger status
  drawns(); //draw the nsamp bar
  drawch(); //draw the channel selection
  drawpb(); //pulserbar
  drawsp();
}
void setup() 
{
  //size(1400,1000);
  //size(1000, 750);
  size(800, 600);
  currWidth = width;
  currHeight = height;
  //w_scrn=currWidth-100;
  //h_scrn=currHeight-150;
  //frame.setResizable(true);
  background(0);
  draw_interface();
  f = createFont("ArialMT", 16);
  textFont(f, 32);
   textAlign(CENTER);
  fill(0,255,0); 
  stroke(0,255,0); 
  text("Welcome to ArduinoScope \n v0.1b (2020-Nov-10)", w_scrn/2, h_scrn/2-90);
  textAlign(CENTER);
  fill(255,100,0); 
  stroke(255,100,0);
  text("Please, select the USB port \n connected to your Arduino!", w_scrn/2, h_scrn/2);
  textFont(f, 16);
  text("Use the 'Select USB port'  tool at the bottom-right corner!\n Make sure the USB-Serial (usually CH340) drivers are installed.", w_scrn/2, h_scrn/2+80);
  textFont(f, 12);
   fill(255); 
  stroke(255);
  text("This program is an opensource initiative, \n for more information check out https://github.com/gwiederhecker/arduino_scope ", w_scrn/2, h_scrn-20);
  //************************
  //font_menu = createFont("ArialMT",10,true);
  //selectSerialPort();
  //openSerialPort();
  //***********************
  //FOLDER SELECT
  //selectFolder("Select a folder to save data and screenshots:", "folderSelected");
  //registerMethod("pre", this); // V2.0.3
}
//void pre() {
//  if (currWidth != width || currHeight != height) {
//    draw_interface();
//    currWidth = width;
//    currHeight = height;
//    w_scrn=int(currWidth*0.9);
//    h_scrn=int(currHeight*600/750);
//    x_ts=x_scrn+w_scrn+20;
//    y_ts=y_scrn;
//    x_ns=x_tb;
//    y_ns=y_tb+(ntbval+2)*h_tb;
//    w_ns=w_tb;
//    h_ns=h_tb;

//    //vertical bar
//    x_vb=x_ns;
//    y_vb=y_ns+(nns+2)*h_ch;
//    w_vb=w_ns;
//    h_vb=h_ns;
  
//    //pulser - everything in units of 1/8th of microsecond
//   x_pb=x_scrn+50;
//    y_pb=y_scrn+h_scrn+40;
//    w_pb=w_scrn-50;
//  }
//}
//Folder select
void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    folder_selected=false;
  } else {
    save_folder = selection.getAbsolutePath();
    println("User selected " + selection.getAbsolutePath());
    folder_selected=true;
  }
}
//*******************
//draw serial port and folder selection
void drawsp() {
  //****** folder
  fill(128); 
  stroke(0, 128, 255);
  rect(x_vb, y_vb+h_usb-25, w_vb, h_vb);
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, 10);
  textAlign(CENTER);
  text("Folder", x_vb+w_vb/2, y_vb+h_usb-25+15);
  //****** usb
  fill(128); 
  stroke(255, 0, 0);
  rect(x_vb, y_vb+h_usb, w_vb, 2*h_vb);
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, fsize-3);
  textAlign(CENTER);
  text("Select", x_vb+w_vb/2, y_vb+h_usb+15);
  text("USB Port", x_vb+w_vb/2, y_vb+h_usb+30);
};
//draw the pulser bar
void drawpb() {
  fill(0); 
  stroke(0);
  rect(x_pb+w_pb, y_pb, 50.0, 4*h_pb);
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, fsize);
  textAlign(LEFT);
  text("pulser on pin 9", x_pb+2, y_pb-2);
  textAlign(RIGHT);
  text("period", x_pb-2, y_pb+h_tb-2);
  text("freq", x_pb-2, y_pb+2*h_tb-2);
  text("length", x_pb-2, y_pb+3*h_tb-2);
  text("dut cyc", x_pb-2, y_pb+4*h_tb-2);
  textAlign(LEFT);
  text("ms", x_pb+w_pb+2, y_pb+h_tb-2);
  text("kHz", x_pb+w_pb+2, y_pb+2*h_tb-2);
  float t=(pls_period[pls_ip]*pls_prescale[pls_ip])/8000.0;
  if (t>1.0)text("ms", x_pb+w_pb+2, y_pb+3*h_tb-2);
  else text("mus", x_pb+w_pb+2, y_pb+3*h_tb-2);
  textAlign(CENTER);
  for (int i=0; i<pls_np; i++) {
    fill(0); 
    stroke(255);
    if (i==pls_ip)fill(128);
    rect(x_pb+i*w_pb/pls_np, y_pb, w_pb/pls_np, h_pb);
    rect(x_pb+i*w_pb/pls_np, y_pb+h_pb, w_pb/pls_np, h_pb);
    fill(255);
    float period=(pls_period[i]*pls_prescale[i])/8000.0;
    text(nf(period, 0, 0), x_pb+(i+0.5)*w_pb/pls_np, y_pb+h_pb-2);
    float freq=1.0/period;
    text(nf(freq, 0, 0), x_pb+(i+0.5)*w_pb/pls_np, y_pb+2*h_pb-2);
  } 
  for (int i=0; i<pls_nl; i++) {
    fill(0); 
    stroke(255);
    if (i==pls_il)fill(128);
    rect(x_pb+i*w_pb/pls_nl, y_pb+2*h_pb, w_pb/pls_nl, h_pb);
    rect(x_pb+i*w_pb/pls_nl, y_pb+3*h_pb, w_pb/pls_nl, h_pb);
    fill(255); 
    stroke(255);
    float len=(pls_len[pls_ip][i]*pls_prescale[pls_ip])/8000.0;
    if (t<=1.0)len*=1e3;
    text(nf(len, 0, 0), x_pb+(i+0.5)*w_pb/pls_nl, y_pb+3*h_pb-2);
    float dut=1.0*pls_len[pls_ip][i]/pls_period[pls_ip];
    text(nf(dut, 0, 0), x_pb+(i+0.5)*w_pb/pls_nl, y_pb+4*h_pb-2);
  }
}

//draw the timebar
void drawtb() {
  fill(255); 
  stroke(255);
  //f = createFont("ArialMT",16);
  f = createFont("Dialog", 12);
  textFont(f, fsize);
  textAlign(CENTER);
  text("ms/div", x_tb+w_tb/2, y_tb-2);
  for (int i=0; i<ntbval; i++) {
    fill(0); 
    stroke(255);
    if (i==tbval)fill(128);
    rect(x_tb, y_tb+i*h_tb, w_tb, h_tb);
    fill(255); 
    stroke(255);
    text(tbms[i], x_tb+0.5*w_tb, y_tb+(i+1)*h_tb-2);
  }
}

//draw the nsamp bar
void drawns() {
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, fsize);
  textAlign(CENTER);
  text("nsamp", x_ns+w_ns/2, y_ns-2);
  for (int i=0; i<nns; i++) {
    fill(0); 
    stroke(255);
    if (i==ins)fill(128);
    rect(x_ns, y_ns+i*h_ns, w_ns, h_ns);
    fill(255); 
    stroke(255);
    text(ns[i], x_ns+0.5*w_ns, y_ns+(i+1)*h_ns-2);
  }
}


//draw the bar for the vertical scale
void drawvb() {
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, fsize);
  textAlign(CENTER);
  text("V/div", x_vb+w_vb/2, y_vb-2);
  fill(0); 
  stroke(255);
  if (ivb==0)fill(128);
  rect(x_vb, y_vb+0*h_vb, w_vb, h_vb);
  fill(255); 
  stroke(255);
  text("1.0", x_vb+0.5*w_vb, y_vb+1*h_tb-2); 
  fill(0); 
  stroke(255);
  if (ivb==1)fill(128);
  rect(x_vb, y_vb+1*h_vb, w_vb, h_vb);
  fill(255); 
  stroke(255);
  text("0.2", x_vb+0.5*w_vb, y_vb+2*h_tb-2);
}

//************************
// draw the trigger status
//************************
void drawts() {
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, fsize);
  textAlign(CENTER);
  text("trigger", x_ts+w_ts/2, y_ts-2);
  fill(0); 
  stroke(255);
  if (trig_mode==0)fill(128);
  rect(x_ts, y_ts, w_ts, h_ts);
  fill(255); 
  stroke(255);
  text("run", x_ts+0.5*w_ts, y_ts+h_ts-3);
  fill(0); 
  stroke(255);
  if (trig_mode==1)fill(128);
  rect(x_ts, y_ts+h_ts, w_ts, h_ts);
  fill(255); 
  stroke(255);
  text("shot", x_ts+0.5*w_ts, y_ts+2*h_ts-3);
  //save button
  fill(0); 
  stroke(255);
  rect(x_ts, y_ts+2*h_ts, w_ts, h_ts);
  fill(save_fill_color);
  stroke(255);
  text("save", x_ts+0.5*w_ts, y_ts+3*h_ts-3);
}

//draw the channel selection
void drawch() {
  fill(255); 
  stroke(255);
  f = createFont("ArialMT", 16);
  textFont(f, fsize);
  textAlign(CENTER);
  text("channels", x_ch+w_ch/2, y_ch-2);
  for (int ichan=0; ichan<maxnchan; ichan++) {
    fill(0); 
    stroke(255);
    if (chanstat[ichan]>0)fill(128);
    rect(x_ch, y_ch+ichan*h_ch, w_ch/3, h_ch);
    fill(chan_color[ichan]); 
    stroke(255);
    text(ichan, x_ch+w_ch/6.0, y_ch+(ichan+1)*h_ch-3);
    fill(0); 
    stroke(255);
    if (chanstat[ichan]==2)fill(128);
    rect(x_ch+w_ch/3.0, y_ch+ichan*h_ch, w_ch/3, h_ch);
    fill(255); 
    stroke(chan_color[ichan]);
    line(x_ch+w_ch*(1.0/2.0), y_ch+(ichan)*h_ch+3, x_ch+w_ch*(1.0/2.0), y_ch+(ichan+1)*h_ch-3);
    line(x_ch+w_ch*(1.0/2.0), y_ch+(ichan)*h_ch+3, x_ch+w_ch*(1.0/2.0)+4, y_ch+(ichan)*h_ch+3);
    line(x_ch+w_ch*(1.0/2.0), y_ch+(ichan+1)*h_ch-3, x_ch+w_ch*(1.0/2.0)-4, y_ch+(ichan+1)*h_ch-3);
    fill(0); 
    stroke(255);
    if (chanstat[ichan]==3)fill(128);
    rect(x_ch+w_ch/1.5, y_ch+ichan*h_ch, w_ch/3, h_ch);
    fill(255); 
    stroke(chan_color[ichan]);
    line(x_ch+w_ch*(5.0/6.0), y_ch+(ichan)*h_ch+3, x_ch+w_ch*(5.0/6.0), y_ch+(ichan+1)*h_ch-3);
    line(x_ch+w_ch*(5.0/6.0), y_ch+(ichan)*h_ch+3, x_ch+w_ch*(5.0/6.0)-4, y_ch+(ichan)*h_ch+3);
    line(x_ch+w_ch*(5.0/6.0), y_ch+(ichan+1)*h_ch-3, x_ch+w_ch*(5.0/6.0)+4, y_ch+(ichan+1)*h_ch-3);
  }
}

void draw_dclevel() {
  //rectrangle to erase previous
  fill(0); 
  stroke(0);
  rect(x_scrn-20, y_scrn, 20,h_scrn+4);
   //**************
  //trigger level
  //for (int ichan=0; ichan<maxnchan; ichan++) {
  //  if ((chanstat[ichan]==0)&&((chanstat[ichan]==2)|(chanstat[ichan]==3))) continue;
  //  this_color = chan_color[ichan];
  //}
  fill(0); 
  stroke(0);
  //rect(x_scrn-10, y_scrn, 10, h_scrn);
  fill(255); 
  stroke(255);
  float y_tl=y_scrn+h_scrn-trig_level/(1.0*maxval)*h_scrn;
  line(x_scrn-10, y_tl, x_scrn, y_tl);
  line(x_scrn-5, y_tl-4, x_scrn, y_tl);
  line(x_scrn-5, y_tl+4, x_scrn, y_tl);
  //************
   //dc level arrow indication
  for (int ichan=0; ichan<maxnchan; ichan++) {
   float y_dclevel=y_scrn+h_scrn-dc_level[ichan]/(1.0*maxval)*h_scrn;

  if (chanstat[ichan]==0) continue;

  fill(255); 
  stroke(chan_color[ichan]);
  line(x_scrn-10, y_dclevel, x_scrn, y_dclevel);
  line(x_scrn-5, y_dclevel-4, x_scrn, y_dclevel);
  line(x_scrn-5, y_dclevel+4, x_scrn, y_dclevel);
  //
  f = createFont("ArialMT", 10);
  textFont(f, 10);
  textAlign(CENTER);
  fill(chan_color[ichan]); 
  stroke(chan_color[ichan]);
  text(ichan, x_scrn-15, y_dclevel+5);//number indicating channel
  }
}
void drawscrn() {
  //trigger offset
  fill(0); 
  stroke(0);
  rect(x_scrn, y_scrn-10, w_scrn, 10);
  fill(255); 
  stroke(255);
  float x_to=x_scrn+w_scrn*(1.0*trig_offset)/(1.0*nsamp);
  line(x_to, y_scrn-10, x_to, y_scrn);
  line(x_to-4, y_scrn-4, x_to, y_scrn);
  line(x_to+4, y_scrn-4, x_to, y_scrn);

  //outline
  fill(0); 
  stroke(255);
  rect(x_scrn, y_scrn, w_scrn, h_scrn);

  //grid
  int ndivy=int(Vmax[ivb]/Vdiv[ivb]);
  int nsdivy=5;
  for (int i=0; i<=ndivy; i++) {
    float y=y_scrn+h_scrn-i*h_scrn*Vdiv[ivb]/Vmax[ivb];
    fill(0); 
    stroke(128);
    line(x_scrn, y, x_scrn+w_scrn, y);
    for (int is=1; is<nsdivy; is++) {
      y-=h_scrn*(Vdiv[ivb]/nsdivy)/Vmax[ivb];
      fill(0); 
      stroke(32);
      if (y>y_scrn)line(x_scrn, y, x_scrn+w_scrn, y);
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
  for (int i=0; i<=ndivx; i++) {
    fill(0); 
    stroke(128);
    float x=x_scrn+i*xdivdist;
    line(x, y_scrn, x, y_scrn+h_scrn);
    for (int is=1; is<nsdivx; is++) {
      x+=xdivdist/nsdivx;
      fill(0); 
      stroke(32);
      if (x<x_scrn+w_scrn)line(x, y_scrn, x, y_scrn+h_scrn);
    }
  }
}

void getdata() {
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
  if (pls_prescale[pls_ip]== 1)port.write(1);
  if (pls_prescale[pls_ip]== 8)port.write(2);
  if (pls_prescale[pls_ip]==64)port.write(3);
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
  while (port.available()>=2*nsamp+1) {
    if (port.read()==255) {
      for (int isamp=0; isamp<nsamp; isamp++) {
        int hsb=port.read();
        int lsb=port.read();
        values[isamp]=hsb*64+(lsb&0xFF);
      }
      doread=false;
    }
  }
}


void drawtraces() {
  //draw the traces
  for (int ichan=0; ichan<maxnchan; ichan++) {
    if (chanstat[ichan]==0) continue;
    // dc level for this channel
    fill(255); 
    stroke(chan_color[ichan]);
    float xprev=0.0; 
    float yprev=0.0;
    int i=fchan;
    for (int isamp=0; isamp<nsamp; isamp++) {
      if (i==ichan) {
        float x=x_scrn+isamp*(w_scrn/(1.0*nsamp));
        float y=y_scrn+h_scrn-gain_level[ichan]*(values[isamp]-dc_level[ichan])*(h_scrn/(1.0*maxval));
        if (isamp>=nchan) line(xprev, yprev, x, y);
        xprev=x;
        yprev=y;
      }
      i=nextchan[i];
    }
  }
}

void draw()
{
  if (port_selected) {
    draw_dclevel();
    drawscrn();
    if (trig_mode==0 || doread)getdata();

    drawtraces(); 
    //draw_dclevel();
    save_mode=false;
  }
  //draw cross markers at mouse position
  if (mousePressed && (mouseButton == LEFT)) {
    //draw_crosses(0,mouseX0,mouseY0);
    draw_crosses(0);
  }
  //draw cross markers at mouse position, keep inital position
  if (mousePressed && (mouseButton == RIGHT)) {
    //draw_crosses(1,mouseX0,mouseY0);
    draw_crosses(1);
  }
}

void keyReleased() {
  if (key == TAB) {
       if(save_folder == null){
      selectFolder("Select a folderto save data and screenshots:", "folderSelected");
    } 
    
      while (save_folder==null){
      delay(500);  
      }
    save_screen();
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
  table.addColumn("time(ms)");
  //creating voltage channels
  for (int ichan=0; ichan<maxnchan; ichan++) {
    if (chanstat[ichan]>0) {
      table.addColumn("voltage_"+str(ichan));
    }
  }
  //creating x-valued rows
  float fsamp=16e6/(13*ADCPS[tbval]*skipsamp[tbval]);
  float xdivdist=1e-3*tbms[tbval]*fsamp*((1.0*w_scrn)/(1.0*nsamp));
  for (int isamp=0; isamp<nsamp/nchan; isamp++) {
      float x = nchan*isamp*(w_scrn/(1.0*nsamp));
      float time_val= x*1.0/xdivdist*tbms[tbval];
      TableRow newRow = table.addRow();
      newRow.setFloat("time(ms)", time_val);
  }
  //attributing y-values for enabled channels
  int ichan0 =0; 
  for (int ichan=0; ichan<maxnchan; ichan++) {
    println("chanstat,", chanstat[ichan]);
    if (chanstat[ichan]>0) {
      println(str(ichan));
      for (int isamp=0; isamp<nsamp/nchan; isamp++) {
        float y = VmaxArduino*values[ichan0+isamp*nchan]/(1.0*maxval);
        //float y = values[ichan0+isamp*nchan];
        table.setFloat(isamp, "voltage_"+str(ichan), y);
      }
      ichan0+=1;
    }
  }
  //String timetag = str(dateTime2);
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
  String formattedDateTime = dateTime2.format(formatter);
  //timetag.replace(':','-');
  println("Saving on folder:"+save_folder);
  println(save_folder+File.separator+"canais_"+formattedDateTime+".csv");
  saveTable(table, save_folder+File.separator+"canais_"+formattedDateTime+".csv");
  saveFrame(save_folder+File.separator+"canais_"+formattedDateTime+".png");
}

void save_screen()
{
  //current date timetag
  LocalDate date = LocalDate.now();
  LocalTime time = LocalTime.now();
  LocalDateTime dateTime2 = LocalDateTime.of(date, time.withNano(0));
  println(dateTime2);
  DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
  String formattedDateTime = dateTime2.format(formatter);
  saveFrame(save_folder+File.separator+"screen_shot_"+formattedDateTime+".png");
}

//void draw_crosses(int persist, int mouseX0, int mouseY0)
void draw_crosses(int persist)
{
  if (persist==0) {
    //println("left");
    if (mouseX<(x_scrn+w_scrn) && mouseX>(x_scrn) && mouseY<(y_scrn+h_scrn) && mouseY>(y_scrn)) {
      stroke(0, 255, 0);
      line(mouseX, y_scrn, mouseX, y_scrn+h_scrn); //vertical
      stroke(0, 255, 0);
      line(x_scrn, mouseY, x_scrn+w_scrn, mouseY); //horizontal
      //tootip
      float voltage_val= -(mouseY-(y_scrn+h_scrn))*5.0/h_scrn;
      //println(tbms[tbval]);
      float fsamp=16e6/(13*ADCPS[tbval]*skipsamp[tbval]);
      float xdivdist=1e-3*tbms[tbval]*fsamp*((1.0*w_scrn)/(1.0*nsamp));
      float time_val= (mouseX-(x_scrn))*1.0/xdivdist*tbms[tbval];
      // println(xdivdist);
      theTooltipString = "("+nf(time_val, 0, 2)+";"+ nf(voltage_val, 0, 2)+")";
      float tw = textWidth(theTooltipString);
      fill(0, 255, 0);
      stroke(0);
      //rect(mouseX-(tw + 4), mouseY, tw + 4, 20);
      rect(2*x_scrn, 2*y_scrn, tw + 20, 30);
      fill(0);
      text(theTooltipString, 2*x_scrn + 2, 2*y_scrn +4, tw+20, 30);
      // set X0,Y0
      mouseX0 = mouseX;
      mouseY0 = mouseY;
    }
  }
  if (persist==1) {
    println("right");
    if (mouseX0<(x_scrn+w_scrn) && mouseX0>(x_scrn) && mouseY0<(y_scrn+h_scrn) && mouseY0>(y_scrn)) {
      //---------------------------
      //initial cross
      //---------------------------
      stroke(0, 200, 0);
      line(mouseX0, y_scrn, mouseX0, y_scrn+h_scrn); //vertical
      stroke(0, 200, 0);
      line(x_scrn, mouseY0, x_scrn+w_scrn, mouseY0); //horizontal
      //---------------------------
      //moving cross
      //---------------------------
      stroke(255, 0, 0);
      line(mouseX, y_scrn, mouseX, y_scrn+h_scrn); //vertical
      stroke(255, 0, 0);
      line(x_scrn, mouseY, x_scrn+w_scrn, mouseY); //horizontal
      //---------------------------
      //tootip vars
      //---------------------------
      //tooltip1
      float voltage_val= -(mouseY0-(y_scrn+h_scrn))*5.0/h_scrn;
      //println(tbms[tbval]);
      float fsamp=16e6/(13*ADCPS[tbval]*skipsamp[tbval]);
      float xdivdist=1e-3*tbms[tbval]*fsamp*((1.0*w_scrn)/(1.0*nsamp));
      float time_val= (mouseX0-(x_scrn))*1.0/xdivdist*tbms[tbval];
      //tooltip2
      float voltage_val2= -(mouseY-(y_scrn+h_scrn))*5.0/h_scrn;
      //println(tbms[tbval]);
      float fsamp2=16e6/(13*ADCPS[tbval]*skipsamp[tbval]);
      float xdivdist2=1e-3*tbms[tbval]*fsamp*((1.0*w_scrn)/(1.0*nsamp));
      float time_val2= (mouseX-(x_scrn))*1.0/xdivdist*tbms[tbval];
      //---------------------------
      //tootip drawing
      //---------------------------
      theTooltipString = "(t0;V0)=("+nf(time_val, 0, 2)+";"+ nf(voltage_val, 0, 2)+")";
      println(theTooltipString);
      float tw = textWidth(theTooltipString);
      fill(0, 255, 255);
      fill(0, 255, 0);
      stroke(0);
      //rect(mouseX-(tw + 4), mouseY, tw + 4, 20);
      rect(2*x_scrn, 2*y_scrn, tw + 20, 30);
      fill(0);
      text(theTooltipString, 2*x_scrn + 2, 2*y_scrn +4, tw+20, 30);
      //---------------------------
      theTooltipString2 = "(t1;V1)=("+nf(time_val2, 0, 2)+";"+ nf(voltage_val2, 0, 2)+")";
      float tw2 = textWidth(theTooltipString2);
      fill(0, 255, 255);
      fill(255, 0, 0);
      stroke(0);
      //rect(mouseX-(tw + 4), mouseY, tw + 4, 20);
      rect(2*x_scrn, 4*y_scrn, tw2 + 20, 30);
      fill(0);
      //text(theTooltipString, mouseX-(tw + 4) + 2, mouseY + 4, tw, 20);
      text(theTooltipString2, 2*x_scrn + 2, 4*y_scrn +4, tw2+20, 30);
      //---------------------------
      theTooltipString3 = "(dt;dV)=("+nf(time_val2-time_val, 0, 2)+";"+ nf(voltage_val2-voltage_val, 0, 2)+")";
      float tw3 = textWidth(theTooltipString3);
      fill(250, 250, 0);
      stroke(0);
      //rect(mouseX-(tw + 4), mouseY, tw + 4, 20);
      rect(2*x_scrn, 6*y_scrn, tw3 + 20, 30);
      fill(0);
      //text(theTooltipString, mouseX-(tw + 4) + 2, mouseY + 4, tw, 20);
      text(theTooltipString3, 2*x_scrn + 2, 6*y_scrn +4, tw3+20, 30);
    }
  }
}

//called everytime a mouse is pressed
void mousePressed() {  //check for mouse clicks

  //pulser bar - period/frequency selection
  if (mouseX>x_pb && mouseX<x_tb+w_pb && mouseY>y_pb && mouseY<y_pb+4*h_pb) {
    if (mouseY<y_pb+2*h_pb) pls_ip=int((mouseX-x_pb)/(w_pb/pls_np));
    if (mouseY>y_pb+2*h_pb) pls_il=int((mouseX-x_pb)/(w_pb/pls_nl));
    drawpb();
  }

  //timebar
  if (mouseX>x_tb && mouseX<x_tb+w_tb && mouseY>y_tb && mouseY<y_tb+ntbval*h_tb) {
    tbval=int((mouseY-y_tb)/h_tb);
    drawtb();
  }

  //nsamp bar
  if (mouseX>x_ns && mouseX<x_ns+w_ns && mouseY>y_ns && mouseY<y_ns+nns*h_ns) {
    ins=int((mouseY-y_ns)/h_ns);
    nsamp=ns[ins];
    if (trig_offset>=nsamp)trig_offset=nsamp-1;
    drawns();
  }

  //vertical scale bar
  if (mouseX>x_vb && mouseX<x_vb+w_vb && mouseY>y_vb && mouseY<y_vb+2*h_vb) {
    ivb=int((mouseY-y_vb)/h_vb);
    drawvb();
  }
  //Select USB port ;
  if (mouseX>x_vb && mouseX<x_vb+w_vb && mouseY>y_vb+h_usb && mouseY<y_vb+2*h_vb+h_usb) {
    selectSerialPort();
  }
  //Select folder; rect(x_vb, y_vb+h_usb-25, w_vb, h_vb);
  if (mouseX>x_vb && mouseX<x_vb+w_vb && mouseY>y_vb+h_usb-25 && mouseY<y_vb+h_vb+h_usb-25) {
    selectFolder("Select a folder to save data and screenshots:", "folderSelected");
  }

  //trigger mode
  if (mouseX>x_ts && mouseX<x_ts+w_ts && mouseY>y_ts && mouseY<y_ts+h_ts) {
    trig_mode=0;
    drawts();
  }
  if (mouseX>x_ts && mouseX<x_ts+w_ts && mouseY>y_ts+h_ts && mouseY<y_ts+2*h_ts) {
    trig_mode=1;
    drawts();
    doread=true;
  }

  //trigger level
  if (mouseX>x_scrn-10 && mouseX<x_scrn && mouseY>y_scrn && mouseY<y_scrn+h_scrn) {
    //trig_level=(mouseY-y_scrn)*255/h_scrn;
    trig_level=(y_scrn+h_scrn-mouseY)*maxval/h_scrn;
  }

  //trigger offset
  if (mouseX>x_scrn && mouseX<x_scrn+w_scrn && mouseY<y_scrn && mouseY>y_scrn-10) {
    trig_offset=(int)((1.0*mouseX-1.0*x_scrn)*(1.0*nsamp)/(1.0*w_scrn));
  }
  //save data
  if (mouseX>x_ts && mouseX<x_ts+w_ts && mouseY>y_ts+2*h_ts && mouseY<y_ts+3*h_ts) {
    trig_mode=0;
    save_mode=!save_mode;

    save_fill_color =0;
    drawts();
    //doread=true;
    //*******
    if(save_folder == null){
      selectFolder("Select a folderto save data and screenshots:", "folderSelected");
    } 
    
      while (save_folder==null){
      delay(500);  
      }
      save_data();
    
    
    delay(500);
    save_fill_color =255;
    drawts();
  } 
  //channel and trigger selection
  if (mouseX>x_ch && mouseX<x_ch+w_ch && mouseY>y_ch && mouseY<y_ch+maxnchan*h_ch) {
    int ichan=int((mouseY-y_ch)/h_ch);
    int ipos=int(3*(mouseX-x_ch)/w_ch);
    if (ipos==0) {
      if (chanstat[ichan]==0)chanstat[ichan]=1;
      else if (chanstat[ichan]>=1 && nchan>1)chanstat[ichan]=0;
    }
    if (ipos==1 || ipos==2) {
      if (chanstat[ichan]==ipos+1)chanstat[ichan]=1;
      else {
        for (int i=0; i<maxnchan; i++)chanstat[i]=min(chanstat[i], 1);
        chanstat[ichan]=ipos+1;
      }
    }

    //calculate some handy numbers
    fchan=0; 
    for (int i=maxnchan-1; i>=0; i--)if (chanstat[i]>0)fchan=i;
    nchan=0; 
    for (int i=0; i<maxnchan; i++)if (chanstat[i]>0)nchan++;
    tchan=maxnchan; 
    for (int i=0; i<maxnchan; i++)if (chanstat[i]>1)tchan=i;
    tmode=0; 
    for (int i=0; i<maxnchan; i++)if (chanstat[i]>1)tmode=chanstat[i];

    //build the nextchan array
    for (int i=0; i<maxnchan; i++) {
      for (int j=1; j<=maxnchan; j++) {
        int i2=(i+j)%maxnchan;
        if (chanstat[i2]>0) {
          nextchan[i]=i2;
          break;
        }
      }
    }
    drawch();
  }
}
