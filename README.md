# arduino_scope
Project for "take-home" Arduino-based scope.
Disclaimer: This project was entirely based on the Instructable post by RGCO user: https://www.instructables.com/id/Another-Arduino-Oscilloscope/

# Background
* Across all the Arduino-based oscilloscopes available online (and there are many out there!), I came across the project by [RGCO](https://www.instructables.com/id/Another-Arduino-Oscilloscope/) which has two great advantages: 
  * The Arduino ADC settings (most important the prescaler factor) are tweaked to run the ADC at maximum speed.
  * User interface written in Processing language, which is Java-based and can be easily compiled for various platforms (Windows, Mac, Linux, Arm, Android,...)
* The purpose of this project is to adapdt RGCO original code to be used as an amateur multi-channel oscilloscope for undergraduate students introductory experimental course on alternate-currents. Specifically [F429](https://www.dac.unicamp.br/sistemas/catalogos/grad/catalogo2020/coordenadorias/0029/0029.html#F%20429) tought at Unicamp for many STEM majors.
# Why changing RGCO original code? 
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
# Folder Strucure
```bash
├── Arduino_Scope_Desktop 
│   ├── Arduino_Scope_desktop.pde # Processing file
│   ├── application.linux-arm64  # Binary app folder
│   ├── application.linux-armv6hf # Binary app folder
│   ├── application.linux32 # Binary app folder
│   ├── application.linux64 # Binary app folder
│   ├── application.macosx # Binary app folder
│   ├── application.windows32 # Binary app folder
│   └── application.windows64 # Binary app folder
├── Arduino_code
│   └── Arduino_Scope.ino # Arduino code 
├── Examples
│   ├── canais_2020-08-18T14:37:13.csv # Example CSV capture with the "save" button
│   └── load_data.ipynb # load and plot csv
├── README.md
└── Screenshots
    ├── capacitor_loaded_trace.png
    ├── save_folder_selection.png
    └── serial_port_selection.png
```
# Roadmap
## Software upgrades
* V0.0 : Current version
* V0.1 : Adapt code to work with Android phones
## Validation and calibration
The lack of an appropriate analog front-end for the ADC poses several issues that must be taken into account when using this as a multi-channel oscilloscope at tens of KHz. A few things that deserve some attention:
   * Output impedance of internal signal generator (using arduino PWM)
   * ADC settling time that create [ghosting effect](https://knowledge.ni.com/KnowledgeArticleDetails?id=kA00Z0000019KzzSAE&l=en-US) between channels.
   * Using common DC offset to enable positive/negative measurements
  
