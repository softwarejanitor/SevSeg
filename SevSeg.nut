/*
 This library allows an Esquilo to easily display numbers and characters on a 4 digit 7-segment 
 display without a separate 7-segment display controller.
 If you have feature suggestions or need support please use the github support page: https://github.com/sparkfun/SevSeg
 Original Library by Dean Reading (deanreading@hotmail.com: http://arduino.cc/playground/Main/SevenSegmentLibrary), 2012
 Improvements by Nathan Seidle, 2012

 Ported from Arduino to Esquilo 20161215 Leeland Heins

 Now works for any digital pin arrangement, common anode and common cathode displays. 
 Added character support including letters A-F and many symbols.
 Hardware Setup: 4 digit 7 segment displays use 12 digital pins. You may need more pins if your display has colons or 
 apostrophes.
 There are 4 digit pins and 8 segment pins. Digit pins are connected to the cathodes for common cathode displays, or anodes 
 for common anode displays. 8 pins control the individual segments (seven segments plus the decimal point). 
 Connect the four digit pins with four limiting resistors in series to any digital or analog pins. Connect the eight segment 
 pins to any digital or analog pins (no limiting resistors needed). See the SevSeg example for more connection information.
 
 SparkFun has a large, 1" 7-segment display that has four digits.
 https://www.sparkfun.com/products/11408
 Looking at the display like this: 8.8.8.8. pin 1 is on the lower row, starting from the left. 
 Pin 12 is the top row, upper left pin.
 
 Pinout:
 1: Segment E
 2: Segment D
 3: Segment DP
 4: Segment C
 5: Segment G
 6: Digit 4
 7: Segment B
 8: Digit 3
 9: Digit 2
 10: Segment F
 11: Segment A
 12: Digit 1
 Software:
 Call SevSeg.Begin in setup.  
 The first argument (boolean) tells whether the display is common cathode (0) or common
 anode (1).
 The next four arguments (bytes) tell the library which arduino pins are connected to
 the digit pins of the seven segment display.  Put them in order from left to right.
 The next eight arguments (bytes) tell the library which arduino pins are connected to
 the segment pins of the seven segment display.  Put them in order a to g then the dp.
 
 In summary, Begin(type, digit pins 1-4, segment pins a-g, dp)
 
 The calling program must run the DisplayString() function repeatedly to get the number displayed.
 Any number between -999 and 9999 can be displayed. 
 To move the decimal place one digit to the left, use '1' as the second
 argument. For example, if you wanted to display '3.141' you would call 
 myDisplay.DisplayString("3141", 1);
 
 */

const HIGH = 1;
const LOW = 0;
const OUTPUT = 1;
const INPUT = 0;

const COMMON_CATHODE = 0;
const COMMON_ANODE = 1;

const BLANK = 16;  // Special character that turns off all segments (we chose 16 as it is the first spot that has this)

// framePeriod controls the length of time between display refreshes
// It's also closely linked to the brightness setting
const FRAMEPERIOD = 2000;
// Total amount of time (in microseconds) for the display frame. 1,000us is roughly 1000Hz update rate
// A framePeriod of:
// 5000 is flickery
// 3000 has good low brightness vs full brightness
// 2000 works well
// 500 seems like the low brightness is pretty bright, not great


// This is the combined array that contains all the segment configurations for many different characters and symbols
characterArray = blob(128);       //                        7-segment map:    0bABCDEFG
characterArray(0)   = 0b1111110,  // 0   "0" hex digits          AAA
characterArray(1)   = 0b0110000,  // 1   "1"                    F   B
characterArray(2)   = 0b1101101,  // 2   "2"                    F   B
characterArray(3)   = 0b1111001,  // 3   "3"                     GGG
characterArray(4)   = 0b0110011,  // 4   "4"                    E   C
characterArray(5)   = 0b1011011,  // 5   "5"                    E   C
characterArray(6)   = 0b1011111,  // 6   "6"                     DDD
characterArray(7)   = 0b1110000,  // 7   "7"
characterArray(8)   = 0b1111111,  // 8   "8"
characterArray(9)   = 0b1111011,  // 9   "9"
characterArray(10)  = 0b1110111,  // 10  "A"
characterArray(11)  = 0b0011111,  // 11  "b"
characterArray(12)  = 0b1001110,  // 12  "C"
characterArray(13)  = 0b0111101,  // 13  "d"
characterArray(14)  = 0b1001111,  // 14  "E"
characterArray(15)  = 0b1000111,  // 15  "F"
characterArray(16)  = 0b0000000,  // 16  NO DISPLAY
characterArray(17)  = 0b0000000,  // 17  NO DISPLAY
characterArray(18)  = 0b0000000,  // 18  NO DISPLAY
characterArray(19)  = 0b0000000,  // 19  NO DISPLAY
characterArray(20)  = 0b0000000,  // 20  NO DISPLAY
characterArray(21)  = 0b0000000,  // 21  NO DISPLAY
characterArray(22)  = 0b0000000,  // 22  NO DISPLAY
characterArray(23)  = 0b0000000,  // 23  NO DISPLAY
characterArray(24)  = 0b0000000,  // 24  NO DISPLAY
characterArray(25)  = 0b0000000,  // 25  NO DISPLAY
characterArray(26)  = 0b0000000,  // 26  NO DISPLAY
characterArray(27)  = 0b0000000,  // 27  NO DISPLAY
characterArray(28)  = 0b0000000,  // 28  NO DISPLAY
characterArray(29)  = 0b0000000,  // 29  NO DISPLAY
characterArray(30)  = 0b0000000,  // 30  NO DISPLAY
characterArray(31)  = 0b0000000,  // 31  NO DISPLAY
characterArray(32)  = 0b0000000,  // 32  ' '
characterArray(33)  = 0b0000000,  // 33  '!'  NO DISPLAY
characterArray(34)  = 0b0100010,  // 34  '"'
characterArray(35)  = 0b0000000,  // 35  '#'  NO DISPLAY
characterArray(36)  = 0b0000000,  // 36  '$'  NO DISPLAY
characterArray(37)  = 0b1100011,  // 37  '%'  -- Use for degrees
characterArray(38)  = 0b0000000,  // 38  '&'  NO DISPLAY
characterArray(39)  = 0b0100000,  // 39  '''
characterArray(40)  = 0b1001110,  // 40  '('
characterArray(41)  = 0b1111000,  // 41  ')'
characterArray(42)  = 0b0000000,  // 42  '*'  NO DISPLAY
characterArray(43)  = 0b0000000,  // 43  '+'  NO DISPLAY
characterArray(44)  = 0b0000100,  // 44  ','
characterArray(45)  = 0b0000001,  // 45  '-'
characterArray(46)  = 0b0000000,  // 46  '.'  NO DISPLAY
characterArray(47)  = 0b0000000,  // 47  '/'  NO DISPLAY
characterArray(48)  = 0b1111110,  // 48  '0'
characterArray(49)  = 0b0110000,  // 49  '1'
characterArray(50)  = 0b1101101,  // 50  '2'
characterArray(51)  = 0b1111001,  // 51  '3'
characterArray(52)  = 0b0110011,  // 52  '4'
characterArray(53)  = 0b1011011,  // 53  '5'
characterArray(54)  = 0b1011111,  // 54  '6'
characterArray(55)  = 0b1110000,  // 55  '7'
characterArray(56)  = 0b1111111,  // 56  '8'
characterArray(57)  = 0b1111011,  // 57  '9'
characterArray(58)  = 0b0000000,  // 58  ':'  NO DISPLAY
characterArray(59)  = 0b0000000,  // 59  ';'  NO DISPLAY
characterArray(60)  = 0b0000000,  // 60  '<'  NO DISPLAY
characterArray(61)  = 0b0000000,  // 61  '='  NO DISPLAY
characterArray(62)  = 0b0000000,  // 62  '>'  NO DISPLAY
characterArray(63)  = 0b0000000,  // 63  '?'  NO DISPLAY
characterArray(64)  = 0b0000000,  // 64  '@'  NO DISPLAY
characterArray(65)  = 0b1110111,  // 65  'A'
characterArray(66)  = 0b0011111,  // 66  'b'
characterArray(67)  = 0b1001110,  // 67  'C'
characterArray(68)  = 0b0111101,  // 68  'd'
characterArray(69)  = 0b1001111,  // 69  'E'
characterArray(70)  = 0b1000111,  // 70  'F'
characterArray(71)  = 0b1011110,  // 71  'G'
characterArray(72)  = 0b0110111,  // 72  'H'
characterArray(73)  = 0b0110000,  // 73  'I'
characterArray(74)  = 0b0111000,  // 74  'J'
characterArray(75)  = 0b0000000,  // 75  'K'  NO DISPLAY
characterArray(76)  = 0b0001110,  // 76  'L'
characterArray(77)  = 0b0000000,  // 77  'M'  NO DISPLAY
characterArray(78)  = 0b0010101,  // 78  'n'
characterArray(79)  = 0b1111110,  // 79  'O'
characterArray(80)  = 0b1100111,  // 80  'P'
characterArray(81)  = 0b1110011,  // 81  'q'
characterArray(82)  = 0b0000101,  // 82  'r'
characterArray(83)  = 0b1011011,  // 83  'S'
characterArray(84)  = 0b0001111,  // 84  't'
characterArray(85)  = 0b0111110,  // 85  'U'
characterArray(86)  = 0b0000000,  // 86  'V'  NO DISPLAY
characterArray(87)  = 0b0000000,  // 87  'W'  NO DISPLAY
characterArray(88)  = 0b0000000,  // 88  'X'  NO DISPLAY
characterArray(89)  = 0b0111011,  // 89  'y'
characterArray(90)  = 0b0000000,  // 90  'Z'  NO DISPLAY
characterArray(91)  = 0b1001110,  // 91  '['
characterArray(92)  = 0b0000000,  // 92  '\'  NO DISPLAY
characterArray(93)  = 0b1111000,  // 93  ']'
characterArray(94)  = 0b0000000,  // 94  '^'  NO DISPLAY
characterArray(95)  = 0b0001000,  // 95  '_'
characterArray(96)  = 0b0000010,  // 96  '`'
characterArray(97)  = 0b1110111,  // 97  'a' SAME AS CAP
characterArray(98)  = 0b0011111,  // 98  'b' SAME AS CAP
characterArray(99)  = 0b0001101,  // 99  'c'
characterArray(100) = 0b0111101,  // 100 'd' SAME AS CAP
characterArray(101) = 0b1101111,  // 101 'e'
characterArray(102) = 0b1000111,  // 102 'F' SAME AS CAP
characterArray(103) = 0b1011110,  // 103 'G' SAME AS CAP
characterArray(104) = 0b0010111,  // 104 'h'
characterArray(105) = 0b0010000,  // 105 'i'
characterArray(106) = 0b0111000,  // 106 'j' SAME AS CAP
characterArray(107) = 0b0000000,  // 107 'k'  NO DISPLAY
characterArray(108) = 0b0110000,  // 108 'l'
characterArray(109) = 0b0000000,  // 109 'm'  NO DISPLAY
characterArray(110) = 0b0010101,  // 110 'n' SAME AS CAP
characterArray(111) = 0b0011101,  // 111 'o'
characterArray(112) = 0b1100111,  // 112 'p' SAME AS CAP
characterArray(113) = 0b1110011,  // 113 'q' SAME AS CAP
characterArray(114) = 0b0000101,  // 114 'r' SAME AS CAP
characterArray(115) = 0b1011011,  // 115 'S' SAME AS CAP
characterArray(116) = 0b0001111,  // 116 't' SAME AS CAP
characterArray(117) = 0b0011100,  // 117 'u'
characterArray(118) = 0b0000000,  // 118 'v'  NO DISPLAY
characterArray(119) = 0b0000000,  // 119 'w'  NO DISPLAY
characterArray(120) = 0b0000000,  // 120 'x'  NO DISPLAY
characterArray(121) = 0b0000000,  // 121 'y'  NO DISPLAY
characterArray(122) = 0b0000000,  // 122 'z'  NO DISPLAY
characterArray(123) = 0b0000000,  // 123 '0b'  NO DISPLAY
characterArray(124) = 0b0000000,  // 124 '|'  NO DISPLAY
characterArray(125) = 0b0000000,  // 125 ','  NO DISPLAY
characterArray(126) = 0b0000000,  // 126 '~'  NO DISPLAY
characterArray(127) = 0b0000000,  // 127 'DEL'  NO DISPLAY
 
class SevSeg
(
    DigitPins = array[4];
    DigitPins[0] = 0;
    DigitPins[1] = 0;
    DigitPins[2] = 0;
    DigitPins[3] = 0;
    SegmentPins = array[8];
    SegmentPins[0] = 0;
    SegmentPins[1] = 0;
    SegmentPins[2] = 0;
    SegmentPins[3] = 0;
    SegmentPins[4] = 0;
    SegmentPins[5] = 0;
    SegmentPins[6] = 0;
    SegmentPins[7] = 0;

    numberOfDigits = 0;
    digit1 = 0;
    digit2 = 0;
    digit3 = 0;
    digit4 = 0;
    digitApostrophe = 0;
    digitColon = 0;
    segmentA = 0;
    segmentB = 0;
    segmentC = 0;
    segmentD = 0;
    segmentE = 0;
    segmentF = 0;
    segmentG = 0;
    segmentDP = 0;
    segmentApostrophe = 0;
    segmentColon = 0;
    mode = 0;

    constructor (mode_in, numOfDigits, dig1, dig2, dig3, dig4, digitCol, digitApos, segA, segB, segC, segD, segE, segF, segG, segDP, segCol, segApos)
    {
        // Bring all the variables in from the caller
        numberOfDigits = numOfDigits;
        digit1 = dig1;
        digit2 = dig2;
        digit3 = dig3;
        digit4 = dig4;
        digitApostrophe = digitApos;
        digitColon = digitCol;
        segmentA = segA;
        segmentB = segB;
        segmentC = segC;
        segmentD = segD;
        segmentE = segE;
        segmentF = segF;
        segmentG = segG;
        segmentDP = segDP;
        segmentApostrophe = segApos;
        segmentColon = segCol;
  
        // Assign input values to variables
        // mode is what the digit pins must be set at for it to be turned on. 0 for common cathode, 1 for common anode
        mode = mode_in;
        if (mode == COMMON_ANODE) {
            DigitOn = HIGH;
            DigitOff = LOW;
            SegOn = LOW;
            SegOff = HIGH;
        } else {
            DigitOn = LOW;
            DigitOff = HIGH;
            SegOn = HIGH;
            SegOff = LOW;
        }

        DigitPins[0] = GPIO(digit1);
        DigitPins[1] = GPIO(digit2);
        DigitPins[2] = GPIO(digit3);
        DigitPins[3] = GPIO(digit4);
        SegmentPins[0] = GPIO(segmentA);
        SegmentPins[1] = GPIO(segmentB);
        SegmentPins[2] = GPIO(segmentC);
        SegmentPins[3] = GPIO(segmentD);
        SegmentPins[4] = GPIO(segmentE);
        SegmentPins[5] = GPIO(segmentF);
        SegmentPins[6] = GPIO(segmentG);
        SegmentPins[7] = GPIO(segmentDP);

        // Turn everything Off before setting pin as output
        // Set all digit pins off. Low for common anode, high for common cathode
        local digit;
        for (digit = 0; digit < numberOfDigits; digit++) {
            digitalWrite(DigitPins[digit], DigitOff);
            pinMode(DigitPins[digit], OUTPUT);
        }
        // Set all segment pins off. High for common anode, low for common cathode
        local seg;
        for (seg = 0; seg < 8; seg++) {
            digitalWrite(SegmentPins[seg], SegOff);
            pinMode(SegmentPins[seg], OUTPUT);
        }

        if (digitColon != 255) {
            digitalWrite(digitColon, DigitOff);
            pinMode(digitColon, OUTPUT);
            digitalWrite(segmentColon, SegOff);
            pinMode(segmentColon, OUTPUT);
        }
        if (digitApostrophe != 255) {
            digitalWrite(digitApostrophe, DigitOff);
            pinMode(digitApostrophe, OUTPUT);
            digitalWrite(segmentApostrophe, SegOff);
            pinMode(segmentApostrophe, OUTPUT);
        }
    }
};

function SevSeg::digitalWrite(pin, st)
{
    if (st == LOW) {
        pin.low();
    } else {
        pin.high();
    }
}

function SevSeg::pinMode(pin, md)
{
    if (md == OUTPUT) {
        pin.output();
    } else {
        pin.input();
    }
}

// Set the display brightness
/*******************************************************************************************/
// Given a value between 0 and 100 (0% and 100%), set the brightness variable on the display
// We need to error check and map the incoming value
function SevSeg::SetBrightness(percentBright)
{
    // Error check and scale brightnessLevel
    if (percentBright > 100) {
        percentBright = 100;
    }
    brightnessDelay = map(percentBright, 0, 100, 0, FRAMEPERIOD);  // map brightnessDelay to 0 to the max which is framePeriod
}


// Refresh Display
/*******************************************************************************************/
// Given a string such as "-A32", we display -A32
// Each digit is displayed for ~2000us, and cycles through the 4 digits
// After running through the 4 numbers, the display is turned off
// Will turn the display on for a given amount of time - this helps control brightness
function SevSeg::DisplayString(toDisplay, DecAposColon)
{
    // For the purpose of this code, digit = 1 is the left most digit, digit = 4 is the right most digit
    local digit;
    for (digit = 1; digit < (numberOfDigits + 1); digit++) {
        switch (digit) {
            case 1:
                digitalWrite(digit1, DigitOn);
                break;
            case 2:
                digitalWrite(digit2, DigitOn);
                break;
            case 3:
                digitalWrite(digit3, DigitOn);
                break;
            case 4:
                digitalWrite(digit4, DigitOn);
                break;
            // This only currently works for 4 digits
        }

        // Here we access the array of segments
        // This could be cleaned up a bit but it works
        // displayCharacter(toDisplay[digit - 1]);  // Now display this digit
        // displayArray (defined above) decides which segments are turned on for each number or symbol
        characterToDisplay = toDisplay[digit - 1];
        // bit 7 enables bit-per-segment control
        if (characterToDisplay & 0x80) {
            // Each bit of characterToDisplay turns on a single segment (from A-to-G)
            if (characterToDisplay & 0x01) digitalWrite(segmentA, SegOn);
            if (characterToDisplay & 0x02) digitalWrite(segmentB, SegOn);
            if (characterToDisplay & 0x04) digitalWrite(segmentC, SegOn);
            if (characterToDisplay & 0x08) digitalWrite(segmentD, SegOn);
            if (characterToDisplay & 0x10) digitalWrite(segmentE, SegOn);
            if (characterToDisplay & 0x20) digitalWrite(segmentF, SegOn);
            if (characterToDisplay & 0x40) digitalWrite(segmentG, SegOn);
        } else {
            chr = characterArray[characterToDisplay];
            if (chr & (1 << 6)) digitalWrite(segmentA, SegOn);
            if (chr & (1 << 5)) digitalWrite(segmentB, SegOn);
            if (chr & (1 << 4)) digitalWrite(segmentC, SegOn);
            if (chr & (1 << 3)) digitalWrite(segmentD, SegOn);
            if (chr & (1 << 2)) digitalWrite(segmentE, SegOn);
            if (chr & (1 << 1)) digitalWrite(segmentF, SegOn);
            if (chr & (1 << 0)) digitalWrite(segmentG, SegOn);
        }
        // Service the decimal point, apostrophe and colon
        if ((DecAposColon & (1 << (digit - 1))) && (digit < 5)) {
            // Test DecAposColon to see if we need to turn on a decimal point
            digitalWrite(segmentDP, SegOn);
        }
        
        udelay(brightnessDelay + 1);  // Display this digit for a fraction of a second (between 1us and 5000us, 500-2000 is pretty good)
        // The + 1 is a bit of a hack but it removes the possible zero display (0 causes display to become bright and flickery)
        // If you set this too long, the display will start to flicker. Set it to 25000 for some fun.

        // Turn off all segments
        digitalWrite(segmentA, SegOff);
        digitalWrite(segmentB, SegOff);
        digitalWrite(segmentC, SegOff);
        digitalWrite(segmentD, SegOff);
        digitalWrite(segmentE, SegOff);
        digitalWrite(segmentF, SegOff);
        digitalWrite(segmentG, SegOff);
        digitalWrite(segmentDP, SegOff);

        // Turn off this digit
        switch (digit) {
            case 1:
              digitalWrite(digit1, DigitOff);
              break;
            case 2:
              digitalWrite(digit2, DigitOff);
              break;
            case 3:
              digitalWrite(digit3, DigitOff);
              break;
            case 4:
              digitalWrite(digit4, DigitOff);
              break;
            // This only currently works for 4 digits
        }
        // The display is on for microSeconds(brightnessLevel + 1), now turn off for the remainder of the framePeriod
        udelay(FRAMEPERIOD - brightnessDelay + 1);  // the +1 is a hack so that we can never have a udelay(0), causes display to flicker         
    }

    // After we've gone through the digits, we control the colon and apostrophe (if the display supports it)
    // Turn on the colon and/or apostrophe
    if ((digitColon != 255) || (digitApostrophe != 255)) {
        if (DecAposColon & (1 << 4)) {
            // Test to see if we need to turn on the Colon
            digitalWrite(digitColon, DigitOn);
            digitalWrite(segmentColon, SegOn);
        }
        if (DecAposColon & (1 << 5)) {
            // Test DecAposColon to see if we need to turn on Apostrophe
            digitalWrite(digitApostrophe, DigitOn);
            digitalWrite(segmentApostrophe, SegOn);
        }
        udelay(brightnessDelay + 1);  // Display this digit for a fraction of a second (between 1us and 5000us, 500-2000 is pretty good)

        // Turn off the colon and/or apostrophe
        digitalWrite(digitColon, DigitOff);
        digitalWrite(segmentColon, SegOff);
        digitalWrite(digitApostrophe, DigitOff);
        digitalWrite(segmentApostrophe, SegOff);    
        udelay(FRAMEPERIOD - brightnessDelay + 1);  // the +1 is a hack so that we can never have a udelay(0), causes display to flicker
    }
}

