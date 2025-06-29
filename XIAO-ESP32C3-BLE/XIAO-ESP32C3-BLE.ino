#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Nordic UART Service UUID definitions
#define SERVICE_UUID        "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"


// Configuration UART pour le GNSS (Broches D6/D7 sur XIAO ESP32C3)
#define RX_PIN D7
#define TX_PIN D6


BLECharacteristic *pCharacteristicTX;
bool deviceConnected = false;
String nmeaBuffer;

class MyServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
     // Serial.println("Device connected");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      BLEDevice::startAdvertising();
      // Serial.println("Device disconnected");
    }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
       // Serial.print("Recu via BLE : ");
       // Serial.println(rxValue);

      // Transmettre les données, sans conversion
      Serial1.write((const char*)rxValue.c_str(), rxValue.length());
    }
  }
};

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200, SERIAL_8N1, RX_PIN, TX_PIN); // <-- À ajouter

  BLEDevice::init("Sonarvision_RTK_02");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks()); // <-- À ajouter

  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Création de la caractéristique TX (Notifications)
  pCharacteristicTX = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_TX,
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristicTX->addDescriptor(new BLE2902());

  // ********** PARTIE MANQUANTE ********** 
  // Création de la caractéristique RX (Write)
  BLECharacteristic *pCharacteristicRX = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID_RX,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristicRX->setCallbacks(new MyCallbacks()); // <-- Essentiel
  // **************************************

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}
void loop() {
  // Lecture des données NMEA du GNSS
while (Serial1.available()) {
    char c = Serial1.read();
    
if (c == '\n') {
    if (deviceConnected && nmeaBuffer.length() > 0) {
        // Ajoute CR si nécessaire :
        String trameAEnvoyer = nmeaBuffer;
        if (!trameAEnvoyer.endsWith("\r")) trameAEnvoyer += "\r\n";
        pCharacteristicTX->setValue(trameAEnvoyer.c_str());
        pCharacteristicTX->notify();
        // Serial.println(nmeaBuffer);
        nmeaBuffer = "";
    }
}
     else if (c != '\r') {
      nmeaBuffer += c;
    }
  }
  
  delay(1);
}