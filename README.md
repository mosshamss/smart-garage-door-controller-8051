# Smart Garage Door Controller using 8051 Assembly

## Project Overview

An embedded-systems project implementing a serial command controlled garage door controller using 8051 Assembly. The program targets an **AT89C51** microcontroller and uses UART commands to select door-open or door-close motor-control outputs. A **16x2 character LCD** shows the corresponding door status.

The repository contains the original Assembly source, its supplied Intel HEX firmware, and a Proteus circuit project. The source and simulation files are included for study and demonstration. The original design and firmware have **not been modified** for this GitHub version.

## Features

- UART-based control using single-character commands (`O` and `C`)
- Two motor-direction control signals on Port 1
- LCD messages for door opening and closing
- Timer-based delays and serial-receive interrupt handling
- Proteus circuit design for an AT89C51 and character LCD

## Command Handling

| Serial character | Firmware behaviour |
| --- | --- |
| `O` | Activates the open-direction output, displays `DOOR OPEN`, then clears the motor-control outputs after a delay |
| `C` | Activates the close-direction output, displays `DOOR CLOSE`, then clears the motor-control outputs after a delay |
| Other character | Clears both motor-control outputs |

The command protocol uses single characters, rather than text commands such as `OPEN` or `CLOSE`.

## Microcontroller Pin Assignment

| Signal | AT89C51 pin / port |
| --- | --- |
| Open-direction motor output | `P1.0` |
| Close-direction motor output | `P1.1` |
| LCD Register Select (RS) | `P1.2` |
| LCD Enable (EN) | `P1.3` |
| LCD data bus | `P2` |
| UART Receive (RXD) | `P3.0` |

The supplied Proteus design uses an **11.0592 MHz** microcontroller clock setting, consistent with the UART baud-rate configuration in the source code.

## Project Files

| File | Description |
| --- | --- |
| [`smartGarage_phase5.asm`](smartGarage_phase5.asm) | Original 8051 Assembly source code |
| [`smartGarage_phase5.hex`](smartGarage_phase5.hex) | Supplied compiled Intel HEX firmware |
| [`simulation/smartGarage.pdsprj`](simulation/smartGarage.pdsprj) | Proteus circuit project |

## Viewing the Simulation

1. Open `simulation/smartGarage.pdsprj` using a compatible version of **Proteus**.
2. Locate the **AT89C51** component and open its properties.
3. Set its **Program File** to the included `smartGarage_phase5.hex` file, using the full local path if required.
4. Check the processor clock setting is **11.0592 MHz**.
5. Inspect the circuit or run the simulation with the serial input arrangement available in your Proteus environment.

**Firmware-path note:** The original Proteus project contains a reference to `lcd.hex`, a filename **not included** in the supplied archive. Point the microcontroller to the provided `smartGarage_phase5.hex` before running the simulation. No changes have been made to the original Proteus project file in this repository.

## Implementation Notes

The firmware configures Timer 1 for serial communication, enables serial-receive interrupts, and uses Timer 0 for software delay routines. Incoming characters are processed by the serial interrupt service routine. The code drives two Port 1 control outputs and writes status messages through a parallel LCD interface.

## Verification and Limitations

- The original archive contains a generated ASEM-51 listing and HEX file, indicating that assembler outputs were produced. The firmware was **not independently rebuilt or simulated** while preparing this repository.
- The code is **command-driven**, not an autonomous parking or obstacle-detection system. No parking occupancy sensor, object-detection logic, or mobile application source code is included.
- The supplied Proteus circuit includes an AT89C51, character LCD, and an output indicator. The firmware defines motor-control signals, but the repository **does not establish a complete physical door-motor assembly**.
- The serial interrupt handler performs blocking display and delay operations. Additional design work would be needed for a production garage-door controller, including safety interlocks, end-stop detection, and motor-driver protection.

## Skills Demonstrated

8051 Assembly, microcontroller programming, UART serial communication, interrupt handling, timer configuration, LCD interfacing, digital I/O, and Proteus circuit simulation.

## Hardware Demonstration

The following video demonstrates the physical smart garage controller prototype.

The system receives commands from a phone and displays the corresponding garage door status on the LCD.

[Watch the Smart Garage Demonstration](media/smart-garage-demo.mp4)
  
## Author

Mohamed Hassanien
