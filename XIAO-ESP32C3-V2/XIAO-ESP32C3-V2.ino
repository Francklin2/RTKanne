#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Nordic UART Service UUID definitions
#define SERVICE_UUID        "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

// Configuration UART pour le GNSS
#define RX_PIN D7
#define TX_PIN D6

// Buffer RTCM avec paramètres stables
#define RTCM_BUFFER_SIZE 1536  // Taille intermédiaire
uint8_t rtcmBuffer[RTCM_BUFFER_SIZE];
int rtcmBufferHead = 0;
int rtcmBufferTail = 0;
unsigned long lastRtcmWrite = 0;

// Paramètres fixes optimisés
const unsigned long RTCM_WRITE_INTERVAL = 1;  // 1ms fixe
const int RTCM_BYTES_PER_WRITE = 80;          // Paquet fixe optimal

BLECharacteristic *pCharacteristicTX;
bool deviceConnected = false;
String nmeaBuffer;

// Fonction pour ajouter au buffer circulaire
void addToRtcmBuffer(const uint8_t* data, size_t len) {
  for (size_t i = 0; i < len; i++) {
    int nextHead = (rtcmBufferHead + 1) % RTCM_BUFFER_SIZE;
    if (nextHead != rtcmBufferTail) {
      rtcmBuffer[rtcmBufferHead] = data[i];
      rtcmBufferHead = nextHead;
    } else {
      // Buffer plein : ignorer les données les plus anciennes (head avance)
      rtcmBufferTail = (rtcmBufferTail + 1) % RTCM_BUFFER_SIZE;
      rtcmBuffer[rtcmBufferHead] = data[i];
      rtcmBufferHead = nextHead;
    }
  }
}

// Fonction pour lire du buffer
int readFromRtcmBuffer(uint8_t* data, int maxLen) {
  int count = 0;
  while (rtcmBufferTail != rtcmBufferHead && count < maxLen) {
    data[count++] = rtcmBuffer[rtcmBufferTail];
    rtcmBufferTail = (rtcmBufferTail + 1) % RTCM_BUFFER_SIZE;
  }
  return count;
}

// Calculer le niveau du buffer
int getBufferLevel() {
  return (rtcmBufferHead - rtcmBufferTail + RTCM_BUFFER_SIZE) % RTCM_BUFFER_SIZE;
}

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  };

  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    BLEDevice::startAdvertising();
  }
};

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    String rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
      addToRtcmBuffer((const uint8_t*)rxValue.c_str(), rxValue.length());
    }
  }
};

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200, SERIAL_8N1, RX_PIN, TX_PIN);

  BLEDevice::init("Sonarvision_RTK_03");
  BLEDevice::setMTU(512);
  
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristicTX = pService->createCharacteristic(
                      CHARACTERISTIC_UUID_TX,
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristicTX->addDescriptor(new BLE2902());

  BLECharacteristic *pCharacteristicRX = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID_RX,
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  pCharacteristicRX->setCallbacks(new MyCallbacks());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void loop() {
  // Gestion RTCM avec paramètres fixes optimisés
  if ((millis() - lastRtcmWrite) >= RTCM_WRITE_INTERVAL) {
    int bufferLevel = getBufferLevel();
    
    if (bufferLevel > 0) {
      uint8_t rtcmData[120]; // Buffer légèrement plus grand que RTCM_BYTES_PER_WRITE
      
      // Lire exactement RTCM_BYTES_PER_WRITE ou ce qui reste
      int bytesToRead = min(bufferLevel, RTCM_BYTES_PER_WRITE);
      int bytesRead = readFromRtcmBuffer(rtcmData, bytesToRead);
      
      if (bytesRead > 0) {
        Serial1.write(rtcmData, bytesRead);
        Serial1.flush();
        
        // Debug monitoring (à commenter en production)
        // if (bufferLevel > 500) {
        //   Serial.printf("RTCM: %d bytes, buffer: %d\n", bytesRead, bufferLevel);
        // }
      }
    }
    lastRtcmWrite = millis();
  }

  // Lecture des données NMEA du GNSS (inchangé)
  while (Serial1.available()) {
    char c = Serial1.read();
    
    if (c == '\n') {
      if (deviceConnected && nmeaBuffer.length() > 0) {
        String trameAEnvoyer = nmeaBuffer;
        if (!trameAEnvoyer.endsWith("\r")) trameAEnvoyer += "\r\n";
        pCharacteristicTX->setValue(trameAEnvoyer.c_str());
        pCharacteristicTX->notify();
        nmeaBuffer = "";
      }
    }
    else if (c != '\r') {
      nmeaBuffer += c;
    }
  }
  
  delay(1); // Retour au délai stable
}