/*
 March 6, 2014
 Spark Fun Electronics
 Nathan Seidle
 Updates by Joel Bartlett

 Ported from Arduino to Esquilo 20161215 Leeland Heins

 This code is originally based Dean Reading's Library deanreading@hotmail.com
 http://arduino.cc/playground/Main/SevenSegmentLibrary
 He didn't have a license on it so I hope he doesn't mind me making it public domain:
 This code is public domain but you buy me a beer if you use this and we meet someday (Beerware license).

 This sketch provides a simple counter example for the HP Bubble display from SparkFun.
 https://www.sparkfun.com/products/12710

 Pinout for HP Bubble Display:
 1:  Cathode 1
 2:  Anode E
 3:  Anode C
 4:  Cathode 3
 5:  Anode dp
 6:  Cathode 4
 7:  Anode G
 8:  Anode D
 9:  Anode F
 10: Cathode 2
 11: Anode B
 12: Anode A
 */

require("GPIO");

// Load the library.
dofile("sd:/SevSeg.nut");

// Create variables
local timer;
local deciSecond = 0;

local displayType = SevSeg::COMMON_CATHODE;  // Your display is either common cathode or common anode

// This pinout is for a bubble dispaly
// Declare what pins are connected to the GND pins (cathodes)
local digit1 = 8;  // Pin 1
local digit2 = 5;  // Pin 10
local digit3 = 11;  // Pin 4
local digit4 = 13;  // Pin 6

// Declare what pins are connected to the segments (anodes)
local segA = 7;  // Pin 12
local segB = 6;  // Pin 11
local segC = 10;  // Pin 3
local segD = 3;  // Pin 8
local segG = 2;  // Pin 7
local segDP = 12;  // Pin 5

local numberOfDigits = 4;  // Do you have a 1, 2 or 4 digit display?

// Create an instance of the object.
myDisplay = SevSeg(displayType, numberOfDigits, digit1, digit2, digit3, digit4, segA, segB, segC, segD, segE, segF, segG, segDP, 255, 255);

myDisplay.SetBrightness(100);  // Set the display to 100% brightness level

timer = millis();

while (1) {
    // Example ways of displaying a decimal number
    char tempString[10];  // Used for sprintf
    sprintf(tempString, "%4d", deciSecond);  // Convert deciSecond into a string that is right adjusted
    //sprintf(tempString, "%d", deciSecond);  // Convert deciSecond into a string that is left adjusted
    //sprintf(tempString, "%04d", deciSecond);  // Convert deciSecond into a string with leading zeros
    //sprintf(tempString, "%4d", deciSecond * -1);  // Shows a negative sign infront of right adjusted number
    //sprintf(tempString, "%4X", deciSecond);  // Count in HEX, right adjusted

    // Produce an output on the display
    myDisplay.DisplayString(tempString, 4);  // (numberToDisplay, decimal point location in binary number [4 means the third digit])

    // Other examples
    // myDisplay.DisplayString(tempString, 0);  // Display string, no decimal point
    // myDisplay.DisplayString("-235", 2);  // Display string, decimal point in second position
    // myDisplay.DisplayString("8888", 15);  // Everything on!

    // Check if 10ms has elapsed
    if (millis() - timer >= 100) {
        timer = millis();
        deciSecond++;
    }

    delay(5);
}

