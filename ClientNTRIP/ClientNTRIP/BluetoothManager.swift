//
//  BluetoothManager.swift
//  Client NTRIP
//
//  Created by francklin nguyen on 28/08/2024.
//

import Foundation
import CoreBluetooth
import CoreLocation

class BluetoothManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedData: Data?
    @Published var bluetoothLocation: CLLocation?
    @Published var fixStatus: String = "Unknown"
    @Published var horizontalAccuracy: Double = 0.0
    @Published var verticalAccuracy: Double = 0.0
    @Published var correctedAltitude: Double = 0.0
    @Published var satelliteCount: Int = 0
    @Published var lastError: String?
    @Published var lastSentDataSize: Double = 0.0
    @Published var connectionStatus: String = "Disconnected"
    @Published var lastReceivedDataSize: Double = 0.0
    @Published var isShowingScanView = false
    @Published var connectedPeripheralName: String?
    @Published var lastConnectedPeripheralIdentifier: UUID?
    @Published var connectedPeripheralUUID: UUID?
    @Published var savedPeripheralUUID: UUID?
    
    @Published var satellitesInView: Int = 0
    @Published var satellitesUsed: Int = 0
    private var activeSatellites: Set<String> = []
    
    private var satelliteCounts: [String: Int] = [:]
    private var centralManager: CBCentralManager!
    private var writeCharacteristic: CBCharacteristic?
    
    private var connectionAttempts = 0
       private let maxConnectionAttempts = 3

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        lastConnectedPeripheralIdentifier = UserDefaults.standard.object(forKey: "LastConnectedPeripheral") as? UUID
    }

    func startScanning() {
        isScanning = true
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
       
        print("Attempting to connect to \(peripheral.name ?? "Unknown Device")...")
    
        connectionAttempts = 0
        attemptConnection(to: peripheral)
        
        stopScanning()
        isShowingScanView = false
        
        centralManager.connect(peripheral, options: nil)
        lastConnectedPeripheralIdentifier = peripheral.identifier
         // Sauvegarder l'identifiant
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "LastConnectedPeripheral")
       //   UserDefaults.standard.set(peripheral.identifier, forKey: "LastConnectedPeripheral")
    }
    
    func connectToLastPeripheral() {
        guard let identifier = lastConnectedPeripheralIdentifier else { return }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
        if let peripheral = peripherals.first {
            connect(to: peripheral)
        }
    }

    
    func reconnectToLastPeripheral() {
         if let identifierString = UserDefaults.standard.string(forKey: "LastConnectedPeripheral"),
            let identifier = UUID(uuidString: identifierString) {
             let knownPeripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
             if let peripheral = knownPeripherals.first {
                 print("Attempting to reconnect to last known peripheral")
                 connect(to: peripheral)
             }
         }
     }
    
    func reconnectToSavedPeripheral() {
        guard let uuid = savedPeripheralUUID else { return }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [uuid])
        if let peripheral = peripherals.first {
            connect(to: peripheral)
        }
    }
 
    func getConnectedPeripheralUUID() -> UUID? {
        return connectedPeripheralUUID
    }

    func sendData(_ data: Data) {
        guard let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic, peripheral.state == .connected else {
            print("Cannot send data: No connected peripheral or write characteristic")
            return
        }
        let kbSent = Double(data.count) / 1024.0
        print("Sending \(String(format: "%.2f", kbSent)) KB to GNSS receiver")
        // Mettre à jour lastReceivedDataSize
         DispatchQueue.main.async {
             self.lastSentDataSize = kbSent
         }

        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    // Déplacé parseNMEAData hors de la fonction peripheral(_:didUpdateValueFor:error:)

    func parseNMEAData(_ data: Data) {
        guard let stringData = String(data: data, encoding: .ascii) ?? String(data: data, encoding: .isoLatin1)  else {
            setError("Failed to decode NMEA data")
            return
        }

        let sentences = stringData.components(separatedBy: .newlines)
        for sentence in sentences {
            if sentence.starts(with: "$GNGGA") {
                parseGGASentence(sentence)
            } else if sentence.starts(with: "$GPGST") || sentence.starts(with: "$GNGST") {
                parseGSTSentence(sentence)
            }
            else if sentence.starts(with: "$GPGSV") || sentence.starts(with: "$GLGSV") ||
                        sentence.starts(with: "$GAGSV") || sentence.starts(with: "$GBGSV") {
                parseGSVSentence(sentence)
            } else if sentence.starts(with: "$GPGSA") || sentence.starts(with: "$GNGSA") {
                parseGSASentence(sentence)
            }
            
            
            
        }
    }

    // Fonctions de parsing rendues publiques
  
    func parseGGASentence(_ sentence: String) {
        let components = sentence.components(separatedBy: ",")
        guard components.count >= 15 else {
            setError("Invalid GGA sentence format")
            return
        }

        guard let latitude = parseCoordinate(components[2], direction: components[3]),
              let longitude = parseCoordinate(components[4], direction: components[5]),
              let altitude = Double(components[9]),
              
                let fixQuality = Int(components[6]) else {
            setError("Failed to parse GGA data")
           
            
            return
        }

        if let altitude = Double(components[9]), let geoidHeight = Double(components[11]) {
            correctedAltitude = altitude + geoidHeight
            // Utilisez correctedAltitude comme l'altitude finale
            }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        bluetoothLocation = CLLocation(coordinate: coordinate,
                                       altitude: altitude,
                                       horizontalAccuracy: horizontalAccuracy,
                                       verticalAccuracy: verticalAccuracy,
                                       timestamp: Date())
        fixStatus = parseFixStatus(fixQuality)
        objectWillChange.send()
    }

    private func parseGSASentence(_ sentence: String) {
        let components = sentence.components(separatedBy: ",")
        guard components.count >= 18 else { return }

        activeSatellites.removeAll()
        
        // Les satellites actifs sont listés dans les champs 3 à 14
        for i in 3...14 {
            let satID = components[i]
            if !satID.isEmpty {
                activeSatellites.insert(satID)
            }
        }
        
        DispatchQueue.main.async {
            self.satellitesUsed = self.activeSatellites.count
        }
    }
    
    private func parseGSVSentence(_ sentence: String) {
         let components = sentence.components(separatedBy: ",")
         guard components.count >= 4 else {
             setError("Invalid GSV sentence format")
             return
         }
         
         // Identifier la constellation
         let constellation = String(sentence.prefix(5))
         
         if let totalMessages = Int(components[1]),
            let messageNumber = Int(components[2]),
            let satellitesInView = Int(components[3]) {
             
             // Mettre à jour le compte pour cette constellation
             satelliteCounts[constellation] = satellitesInView
             
             // Si c'est le dernier message de la série pour cette constellation,
             // mettre à jour le compte total
             if messageNumber == totalMessages {
                 updateTotalSatelliteCount()
             }
         }
     }

     private func updateTotalSatelliteCount() {
         let totalCount = satelliteCounts.values.reduce(0, +)
         DispatchQueue.main.async {
             self.satelliteCount = totalCount
         }
     }

    func parseGSTSentence(_ sentence: String) {
        let components = sentence.components(separatedBy: ",")
        guard components.count >= 8 else {
            setError("Invalid GST sentence format")
            return
        }

        if let hAcc = Double(components[6]), let vAcc = Double(components[7]) {
            horizontalAccuracy = hAcc
            verticalAccuracy = vAcc
            objectWillChange.send()
        } else {
            setError("Failed to parse accuracy data")
        }
    }

    func parseCoordinate(_ value: String, direction: String) -> Double? {
        guard let doubleValue = Double(value) else { return nil }
        let degrees = floor(doubleValue / 100)
        let minutes = doubleValue.truncatingRemainder(dividingBy: 100)
        var coordinate = degrees + (minutes / 60)
        if direction == "S" || direction == "W" {
            coordinate = -coordinate
        }
        return coordinate
    }

    func parseFixStatus(_ quality: Int) -> String {
        switch quality {
        case 0: return "Invalid"
        case 1: return "GPS fix"
        case 2: return "DGPS fix"
        case 4: return "RTK fixed"
        case 5: return "RTK float"
        default: return "Unknown"
        }
    }

    func setError(_ message: String) {
        lastError = message
        objectWillChange.send()
    }
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
       
        case .poweredOn:
                print("Bluetooth is powered on")
                startScanning()
        case .poweredOff:
                print("Bluetooth is powered off")
                stopScanning()
        case .unsupported:
            print("Bluetooth is not supported on this device")
        case .unauthorized:
            print("Bluetooth use is not authorized")
        case .resetting:
            print("Bluetooth is resetting")
        case .unknown:
            print("Bluetooth state is unknown")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       
        print("Connected to peripheral: \(peripheral.name ?? "Unknown Device")")
        connectedPeripheral = peripheral
        connectedPeripheralUUID = peripheral.identifier
        connectedPeripheralName = peripheral.name ?? "Unknown Device"
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
  //      guard let services = peripheral.services else { return }
  //      for service in services {
  //          peripheral.discoverCharacteristics(nil, for: service)
  //      }
  //  }
        if let error = error {
               print("Error discovering services: \(error.localizedDescription)")
               return
           }
           
           guard let services = peripheral.services else {
               print("No services found")
               return
           }
           
           for service in services {
               print("Discovered service: \(service.uuid)")
               peripheral.discoverCharacteristics(nil, for: service)
           }
       }
        
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) {
                writeCharacteristic = characteristic
                print("Found write characteristic: \(characteristic.uuid)")
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Enabled notifications for characteristic: \(characteristic.uuid)")
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiving data: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value else {
            print("No data received")
            return
        }
        
        // Mettre à jour la propriété publiée avec les nouvelles données
        DispatchQueue.main.async {
            self.receivedData = data
            self.parseNMEAData(data)
        }
        

        
    }
    
    
    func retrievePeripheral(withIdentifier identifier: UUID) {
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
        if let peripheral = peripherals.first {
            centralManager.connect(peripheral, options: nil)
        }
    }
    func checkBluetoothAuthorization() {
        switch CBCentralManager.authorization {
        case .allowedAlways:
            print("Bluetooth is authorized")
        case .denied, .restricted:
            setError("Bluetooth access is denied or restricted")
        case .notDetermined:
            print("Bluetooth authorization not determined")
        @unknown default:
            setError("Unknown Bluetooth authorization status")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        setError("Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")
        
        print("Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")
           
           // Tentative de reconnexion après un délai
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                 self.attemptConnection(to: peripheral)
             }
        
      //  DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      //         print("Attempting to reconnect after failure...")
      //         self.centralManager.connect(peripheral, options: nil)
      //     }
        
    }
    
    func resetBluetoothManager() {
        centralManager = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(error?.localizedDescription ?? "No error")")
        connectedPeripheral = nil
        
        // Tentative de reconnexion automatique
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Attempting to reconnect...")
            self.centralManager.connect(peripheral, options: nil)
        }
    }
    
    private func attemptConnection(to peripheral: CBPeripheral) {
           guard connectionAttempts < maxConnectionAttempts else {
               print("Max connection attempts reached")
               return
           }
           
           connectionAttempts += 1
           print("Connection attempt \(connectionAttempts)")
           centralManager.connect(peripheral, options: nil)
       }
    
    
}

