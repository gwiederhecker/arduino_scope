# arduino_scope
Project for "take-home" Arduino-based scope.
Disclaimer: This project was entirely based on the Instructable post by RGCO user: https://www.instructables.com/id/Another-Arduino-Oscilloscope/

# Background
* Across all the Arduino-based oscilloscopes available online (and there are many out there!), I came across the project by [RGCO](https://www.instructables.com/id/Another-Arduino-Oscilloscope/) which has two great advantages: 
  * The Arduino ADC settings (most important the prescaler factor) is tweaked to run the ADC at maximum speed
  * User interface written in Processing language, which is Java-based and be easily compiled for various platforms (Windows, Mac, Linux, Arm, Android,...)
* The purpose of this project is to adapdt RGCO original code to be used as an amateur multi-channel oscilloscope for undergraduate students introductory experimental course on alternate-currents. Specifically [F429](https://www.dac.unicamp.br/sistemas/catalogos/grad/catalogo2020/coordenadorias/0029/0029.html#F%20429) tought at Unicamp for many STEM majors.
# Why changing RGCO  original code? 
I reproduce here the original features quoted at [Instructables.com]( https://www.instructables.com/id/Another-Arduino-Oscilloscope/):
  * No extra hardware beyond an Arduino connected to a PC
  * Sample rate of up to 77ks/s
  * Up to six input channels
  * 10-bit precision
  * Two vertical ranges (0-5V or 0-1.1V)
  * Trigger on rising or falling edge
  * Free running or one-shot operation
  * Integrated pulse generator
  * Display on computer screen using open-source ‘processing’ sketch
  
On top of these, I would add that this is an extremely cheap scope, even when compared to projects like [EspoTek Labrador](https://github.com/EspoTek/Labrador). Of course it should not perform as well, given the complete lack of an analog front-end.
* For a "take-home" deployment, a couple of features were missing in the original implementation
  * Selection of the proper USB port that is connected to the Arduino
  * Hability to save the data to a file.
  * Compiled versions so students could plug and play to get their analysis going.
* These three items are the major contributions of the this project, when compared to the [original post](https://www.instructables.com/id/Another-Arduino-Oscilloscope/) by RGCO.

  
