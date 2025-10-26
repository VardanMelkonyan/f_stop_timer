/*
  FStopTimer_BLE_Relay_Classic.ino
  Library: ESP32 BLE Arduino (Kolban) - <BLEDevice.h>

  - Button: falling-edge debounced.
  - OFF → ON requires double-press within window.
  - ON  → OFF is single press.
  - BLE Command Characteristic accepts "ON", "OFF", "TOGGLE".
  - BLE Status Characteristic is READ + NOTIFY ("ON"/"OFF").
  - Restarts advertising on disconnect (iOS-friendly advertising settings).
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

/* ----------------------------- Pins & Config ----------------------------- */
#define BUTTON_PIN 27
#define RELAY_PIN  22

// If your relay module is ACTIVE-LOW, set to 1.
#define RELAY_ACTIVE_LOW 0

// Debounce & double-press timing
const uint32_t DEBOUNCE_MS = 30;
const uint32_t DOUBLE_PRESS_WINDOW_MS = 400;

/* ----------------------------- BLE UUIDs --------------------------------- */
// Reuse your stable UUIDs if you want
#define SERVICE_UUID        "FA71809B-52E8-4DF2-BCE1-9C4D42311C97"
#define CHAR_CMD_UUID       "E8C858FA-E034-4EBF-A8C6-397401281056"
#define CHAR_STATUS_UUID    "58707319-E7C8-40BA-8A05-A3AE010B4997"

/* ----------------------------- Button State ------------------------------ */
int lastRaw = HIGH;
int stableState = HIGH;
uint32_t lastChangeMs = 0;

bool relayOn = false;
bool waitingSecondPress = false;
uint32_t firstPressTime = 0;

/* ----------------------------- BLE Globals ------------------------------- */
BLECharacteristic* cmdChar = nullptr;
BLECharacteristic* statusChar = nullptr;

/* ----------------------------- Helpers ----------------------------------- */
void applyRelay(bool on) {
  if (RELAY_ACTIVE_LOW) {
    digitalWrite(RELAY_PIN, on ? LOW : HIGH);
  } else {
    digitalWrite(RELAY_PIN, on ? HIGH : LOW);
  }
}

void publishStatus() {
  if (!statusChar) return;
  const char* s = relayOn ? "ON" : "OFF";
  statusChar->setValue((uint8_t*)s, strlen(s));
  statusChar->notify(); // OK even if no subscribers (just no effect)
}

void setRelay(bool on, const char* reason) {
  relayOn = on;
  applyRelay(on);
  Serial.print(on ? "ON  — " : "OFF — ");
  Serial.println(reason);
  publishStatus();
}

/* ----------------------------- Button Logic ------------------------------ */
void onPress() {
  if (relayOn) {
    // ON → single press turns OFF
    waitingSecondPress = false;
    setRelay(false, "Button single press (ON→OFF)");
    return;
  }

  // OFF → require double press to turn ON
  if (!waitingSecondPress) {
    waitingSecondPress = true;
    firstPressTime = millis();
    Serial.println("First press (OFF) — waiting for second press...");
  } else {
    if (millis() - firstPressTime <= DOUBLE_PRESS_WINDOW_MS) {
      waitingSecondPress = false;
      setRelay(true, "Button double press (OFF→ON)");
    } else {
      firstPressTime = millis();
      Serial.println("Window expired; counting as new first press.");
    }
  }
}

/* ----------------------------- BLE Callbacks ----------------------------- */
class CmdCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic* c) override {
    String v = c->getValue().c_str();  // convert to Arduino String
    v.toUpperCase();                   // optional: make it case-insensitive

    if (v == "ON")          setRelay(true,  "BLE cmd");
    else if (v == "OFF")    setRelay(false, "BLE cmd");
    else if (v == "TOGGLE") setRelay(!relayOn, "BLE toggle");
  }
};


class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* s) override {
    Serial.println("Central connected");
    publishStatus(); // push current state after a central connects
  }
  void onDisconnect(BLEServer* s) override {
    Serial.println("Central disconnected");
    BLEDevice::startAdvertising(); // resume advertising for iOS to see again
  }
};

/* -------------------------------- Setup ---------------------------------- */
void setup() {
  Serial.begin(115200);

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(RELAY_PIN, OUTPUT);

  // Start OFF
  applyRelay(false);
  relayOn = false;

  // ---- BLE init (classic library) ----
  BLEDevice::init("FStopTimer"); // device name
  BLEDevice::setPower(ESP_PWR_LVL_P7); // optional

  BLEServer* server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());

  BLEService* svc = server->createService(SERVICE_UUID);

  // Command characteristic (Write)
  cmdChar = svc->createCharacteristic(
      CHAR_CMD_UUID,
      BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR
  );
  cmdChar->setCallbacks(new CmdCallback());

  // Status characteristic (Read + Notify)
  statusChar = svc->createCharacteristic(
      CHAR_STATUS_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY
  );
  // CCCD needed for iOS to enable notifications
  statusChar->addDescriptor(new BLE2902());
  statusChar->setValue("OFF");

  svc->start();

  // --- Advertising (iOS-friendly) ---
  BLEAdvertising* adv = BLEDevice::getAdvertising();
  adv->addServiceUUID(SERVICE_UUID);
  adv->setScanResponse(true);     // put extra data (like UUID) in scan response if needed
  adv->setMinPreferred(0x06);     // iOS connection parameter hints
  adv->setMinPreferred(0x12);     // (common pattern in Kolban examples)

  BLEDevice::startAdvertising();
  Serial.println("BLE ready, advertising.");
}

/* --------------------------------- Loop ---------------------------------- */
void loop() {
  // --- Debounce ---
  int raw = digitalRead(BUTTON_PIN);
  if (raw != lastRaw) {
    lastRaw = raw;
    lastChangeMs = millis();
  }

  if ((millis() - lastChangeMs) >= DEBOUNCE_MS && raw != stableState) {
    stableState = raw;
    // Act only on PRESS (falling edge: HIGH -> LOW)
    if (stableState == LOW) onPress();
  }

  // --- Timeout the waiting window when OFF ---
  if (!relayOn && waitingSecondPress) {
    if (millis() - firstPressTime > DOUBLE_PRESS_WINDOW_MS) {
      waitingSecondPress = false;
    }
  }
}
