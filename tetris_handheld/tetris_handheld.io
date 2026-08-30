#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>
#include <avr/pgmspace.h>

constexpr byte SCREEN_WIDTH = 128, SCREEN_HEIGHT = 64;
constexpr byte BOARD_COLS = 10, BOARD_ROWS = 20;
constexpr byte CELL_SIZE = 3, BOARD_X = 4, BOARD_Y = 2;
constexpr byte PIECE_SIZE = 4, PIECE_COUNT = 7;
constexpr byte BTN_LEFT = 2, BTN_RIGHT = 3, BTN_ROTATE = 4, BTN_DROP = 5;
constexpr unsigned long INITIAL_FALL_INTERVAL = 500;

Adafruit_SH1106G display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);
byte board[BOARD_ROWS][BOARD_COLS];

// One 16-bit mask per 4x4 rotation, read left-to-right and top-to-bottom.
const uint16_t pieces[PIECE_COUNT][4] PROGMEM = {
  {0x0F00, 0x2222, 0x00F0, 0x4444}, // I
  {0x6600, 0x6600, 0x6600, 0x6600}, // O
  {0x4E00, 0x4640, 0x0E40, 0x4C40}, // T
  {0x6C00, 0x4620, 0x06C0, 0x8C40}, // S
  {0xC600, 0x2640, 0x0C60, 0x4C80}, // Z
  {0x8E00, 0x6440, 0x0E20, 0x44C0}, // J
  {0x2E00, 0x4460, 0x0E80, 0xC440}  // L
};

int8_t pieceX, pieceY;
byte currentPiece, nextPiece, currentRotation;
unsigned int clearedLines;
byte level;
bool gameOver;
unsigned long lastFallTime, fallInterval;
bool lastButtonState[4] = {HIGH, HIGH, HIGH, HIGH};
const byte buttonPins[4] = {BTN_LEFT, BTN_RIGHT, BTN_ROTATE, BTN_DROP};

bool pieceCellFilled(byte piece, byte rotation, byte x, byte y) {
  const uint16_t mask = pgm_read_word(&pieces[piece][rotation]);
  return mask & (0x8000UL >> (y * PIECE_SIZE + x));
}

bool canPlacePiece(int8_t newX, int8_t newY, byte rotation) {
  for (byte py = 0; py < PIECE_SIZE; ++py) {
    for (byte px = 0; px < PIECE_SIZE; ++px) {
      if (!pieceCellFilled(currentPiece, rotation, px, py)) continue;

      const int8_t x = newX + px;
      const int8_t y = newY + py;
      if (x < 0 || x >= BOARD_COLS || y >= BOARD_ROWS) return false;
      if (y >= 0 && board[y][x]) return false;
    }
  }
  return true;
}

void lockCurrentPiece() {
  for (byte py = 0; py < PIECE_SIZE; ++py) {
    for (byte px = 0; px < PIECE_SIZE; ++px) {
      if (!pieceCellFilled(currentPiece, currentRotation, px, py)) continue;

      const int8_t x = pieceX + px;
      const int8_t y = pieceY + py;
      if (x >= 0 && x < BOARD_COLS && y >= 0 && y < BOARD_ROWS) board[y][x] = 1;
    }
  }
}

void updateLevel() {
  level = min(10, 1 + clearedLines / 10);
  fallInterval = max(140UL, INITIAL_FALL_INTERVAL - (unsigned long)(level - 1) * 40);
}

void clearCompletedLines() {
  for (int y = BOARD_ROWS - 1; y >= 0; --y) {
    bool full = true;
    for (byte x = 0; x < BOARD_COLS; ++x) full &= board[y][x] != 0;
    if (!full) continue;

    for (int row = y; row > 0; --row)
      memcpy(board[row], board[row - 1], BOARD_COLS);
    memset(board[0], 0, BOARD_COLS);
    ++clearedLines;
    updateLevel();
    ++y; // Recheck the row after shifting.
  }
}

void spawnNewPiece() {
  currentPiece = nextPiece;
  nextPiece = random(PIECE_COUNT);
  currentRotation = 0;
  pieceX = 3;
  pieceY = 0;
  gameOver = !canPlacePiece(pieceX, pieceY, currentRotation);
}

void finishFallingPiece() {
