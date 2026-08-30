# Arduino Tetris Handheld

A portable Tetris handheld built with an Arduino Nano, a 128×64 SH1106 OLED display, tactile controls, and memory-efficient C++ game logic.

## Description

This project recreates Tetris on an Arduino Nano and a compact OLED display. It uses four physical buttons for movement, rotation, hard drop, and restarting the game.

The game includes all seven tetrominoes, collision detection, piece stacking, completed-line clearing, level progression, increasing fall speed, a next-piece preview, and game-over detection.

Tetromino rotations are stored as 16-bit masks in flash memory using `PROGMEM`, reducing memory usage on the Arduino Nano.

## Features

- Seven standard tetrominoes
- Left and right movement
- Piece rotation
- Hard drop
- Collision detection
- Piece stacking
- Completed-line clearing
- Cleared-line counter
- Level progression
- Increasing fall speed
- Next-piece preview
- Game-over detection
- Button-controlled restart
- Memory-efficient tetromino storage
- OLED updates only when the game state changes

## Hardware

- Arduino Nano or compatible ATmega328P board
- 128×64 SH1106 I²C OLED display
- Four tactile push buttons
- Breadboard or perfboard
- Jumper wires
- USB cable or suitable power source
- Female headers, solder, and flux for the permanent build

## Software

- Arduino IDE
- C++
- Adafruit GFX Library
- Adafruit SH110X Library
- Wire Library

## Controls

| Button | Arduino pin | Action |
|---|---:|---|
| White | D2 | Move left |
| Yellow | D3 | Move right |
| Black | D4 | Rotate |
| Green | D5 | Hard drop |

When the game is over, press the black rotation button to restart.

## Wiring

### OLED display

| OLED pin | Arduino Nano |
|---|---|
| VCC | 5V |
| GND | GND |
| SDA | A4 |
| SCL | A5 |

### Buttons

Connect one side of each button to its assigned digital pin and the other side to GND. The sketch uses the Arduino’s internal pull-up resistors with `INPUT_PULLUP`.

| Button | Digital pin |
|---|---:|
| Left | D2 |
| Right | D3 |
| Rotate | D4 |
| Hard drop | D5 |

> Confirm that your particular SH1106 display supports the selected supply voltage before connecting it.

## Installation

1. Install the [Arduino IDE](https://www.arduino.cc/en/software).
2. Open the Arduino Library Manager.
3. Install **Adafruit GFX Library**.
4. Install **Adafruit SH110X**.
5. Download or clone this repository.
6. Open `tetris_handheld/tetris_handheld.ino`.
7. Select **Arduino Nano** under **Tools → Board**.
8. Select the correct processor and serial port.
9. Compile and upload the sketch.

## How It Works

The game board is represented by a 20×10 array. Each tetromino rotation is stored as a compact 16-bit mask in program memory. Before moving or rotating a piece, the game checks the requested position for collisions with the board boundaries and previously placed blocks.

When a piece can no longer fall, it is added to the board. Completed rows are removed, the remaining rows shift downward, and the line counter and level are updated. The automatic fall interval decreases as the level increases.
