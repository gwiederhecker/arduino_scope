# arduino_scope
Project for "take-home" Arduino-based scope.
Disclaimer: This project was entirely based on the Instructable post by RGCO user: https://www.instructables.com/id/Another-Arduino-Oscilloscope/

# Background
* The purpose of this project is to adapdt RGCO original code to be used as an amateur multi-channel oscilloscope for undergraduate students introductory experimental course on alternate-currents. Specifically [F429](https://www.dac.unicamp.br/sistemas/catalogos/grad/catalogo2020/coordenadorias/0029/0029.html#F%20429) tought at Unicamp.
* Across all the Arduino-based oscilloscopes available online (and there are many out there!), I came across the project by RGCO which has two great advantages:
  * The Arduino ADC settings (most important the prescaler factor) is tweaked to run the ADC at maximum speed
  * User interface written in Processing language, which is Java-based and be easily compiled for various platforms (Windows, Mac, Linux, Arm, Android,...)
  
