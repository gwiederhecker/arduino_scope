<Qucs Schematic 0.0.19>
<Properties>
  <View=-240,-193,830,645,1.14304,0,0>
  <Grid=10,10,1>
  <DataSet=arduino_scope_passa_alta.dat>
  <DataDisplay=arduino_scope_passa_alta.dpl>
  <OpenDisplay=1>
  <Script=arduino_scope_passa_alta.m>
  <RunScript=0>
  <showFrame=0>
  <FrameText0=Title>
  <FrameText1=Drawn By:>
  <FrameText2=Date:>
  <FrameText3=Revision:>
</Properties>
<Symbol>
</Symbol>
<Components>
  <GND * 1 500 390 0 0 0 0>
  <R R2 1 500 230 15 -26 0 1 "Rin" 1 "26.85" 0 "0.0" 0 "0.0" 0 "26.85" 0 "US" 0>
  <R R3 1 500 360 15 -26 0 1 "Rin" 1 "26.85" 0 "0.0" 0 "0.0" 0 "26.85" 0 "US" 0>
  <GND * 1 660 390 0 0 0 0>
  <R R4 1 660 360 15 -26 0 1 "100M" 1 "26.85" 0 "0.0" 0 "0.0" 0 "26.85" 0 "US" 0>
  <Vdc V3 1 640 190 -26 -42 0 2 "5" 1>
  <GND * 1 680 190 0 0 0 0>
  <R R1 1 -50 240 -26 15 0 0 "Rth" 1 "26.85" 0 "0.0" 0 "0.0" 0 "26.85" 0 "US" 0>
  <GND * 1 -140 350 0 0 0 0>
  <GND * 1 30 350 0 0 0 0>
  <R R6 1 30 320 15 -26 0 1 "Rth" 1 "26.85" 0 "0.0" 0 "0.0" 0 "26.85" 0 "US" 0>
  <Eqn Eqn1 1 340 500 -23 13 0 0 "Rth=50" 1 "Tsim=5*T0" 1 "Cin=22u" 1 "Rin=25k" 1 "yes" 0>
  <.DC DC1 1 180 500 0 33 0 0 "26.85" 0 "0.001" 0 "1 pA" 0 "1 uV" 0 "no" 0 "150" 0 "no" 0 "none" 0 "CroutLU" 0>
  <GND * 1 300 320 0 0 0 0>
  <Eqn Eqn2 1 460 500 -23 13 0 0 "Tstep=1e-2*T0" 1 "T0=5e-3" 1 "Tr0=1e-3*T0" 1 "yes" 0>
  <.TR TR1 1 60 500 0 51 0 0 "lin" 1 "0" 1 "Tsim" 1 "1000" 0 "Trapezoidal" 0 "2" 0 "1 ns" 0 "1e-16" 0 "150" 0 "0.001" 0 "1 pA" 0 "1 uV" 0 "26.85" 0 "1e-3" 0 "1e-6" 0 "1" 0 "CroutLU" 0 "no" 0 "yes" 0 "0" 0>
  <Vrect V1 1 -140 320 18 -26 0 1 "5" 1 "T0" 1 "T0" 1 "10us" 0 "10us" 0 "0 ns" 0>
  <C C1 1 450 290 -26 17 0 0 "Cin" 1 "-2.5V" 0 "neutral" 0>
  <C C2 1 220 260 -26 -41 0 2 "470n" 1 "" 0 "neutral" 0>
  <R R5 1 300 290 -51 -26 0 3 "960" 1 "26.85" 0 "0.0" 0 "0.0" 0 "26.85" 0 "US" 0>
</Components>
<Wires>
  <500 260 500 290 "" 0 0 0 "">
  <500 290 500 330 "" 0 0 0 "">
  <480 290 500 290 "" 0 0 0 "">
  <500 290 660 290 "" 0 0 0 "">
  <660 290 660 330 "" 0 0 0 "">
  <500 190 500 200 "" 0 0 0 "">
  <500 190 610 190 "" 0 0 0 "">
  <670 190 680 190 "" 0 0 0 "">
  <-140 240 -80 240 "" 0 0 0 "">
  <-140 240 -140 290 "" 0 0 0 "">
  <30 240 30 260 "" 0 0 0 "">
  <-20 240 30 240 "" 0 0 0 "">
  <30 260 30 290 "" 0 0 0 "">
  <30 260 190 260 "Vin" 150 160 92 "">
  <420 260 420 290 "" 0 0 0 "">
  <250 260 300 260 "" 0 0 0 "">
  <300 260 420 260 "Vout" 350 160 61 "">
  <660 290 660 290 "Varduino" 640 260 0 "">
</Wires>
<Diagrams>
  <Rect -120 82 820 186 3 #c0c0c0 1 00 1 0 0.001 0.01 0 -5 1 5 1 -1 0.5 1 315 0 225 "" "" "">
	<"Vin.Vt" #0000ff 1 3 0 0 0>
	<"Varduino.Vt" #ff0000 2 3 0 2 0>
	<"Vout.Vt" #408000 2 3 0 1 0>
  </Rect>
</Diagrams>
<Paintings>
  <Rectangle 420 170 140 250 #000000 2 3 #c0c0c0 1 0>
  <Rectangle 410 130 380 320 #0f80ff 2 2 #c0c0c0 1 0>
  <Text 580 430 12 #000000 0 "Entrada analógica Arduino (AI0-AI5)">
  <Rectangle 600 140 90 110 #000000 2 3 #c0c0c0 1 0>
  <Text 700 150 12 #000000 0 "Tensão DC\nArduino (+5V)">
  <Text 450 140 12 #000000 0 "Acoplamento AC\nSoma 2.5 V">
  <Rectangle -180 190 180 220 #999999 2 3 #b3b3b3 7 1>
  <Rectangle 10 190 80 220 #000000 2 3 #c0c0c0 1 0>
  <Text -140 420 12 #000000 0 "Saída digital Arduino\n(pino D9)">
  <Rectangle -200 130 310 330 #0f80ff 2 2 #c0c0c0 1 0>
  <Text 0 420 12 #000000 0 "Divisor de tensão">
  <Rectangle 600 280 130 140 #999999 2 3 #b3b3b3 7 1>
  <Rectangle 170 210 180 190 #ff0000 2 3 #c0c0c0 1 0>
  <Text 220 410 12 #000000 0 "Circuito em teste">
</Paintings>
