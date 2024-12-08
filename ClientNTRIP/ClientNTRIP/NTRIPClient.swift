//
//  NTRIPClient.swift
//  Client NTRIP
//
//  Created by francklin nguyen on 16/08/2024.
//

import Foundation
import SwiftData
import Combine
import CoreLocation

class NTRIPClient: NSObject, ObservableObject, CLLocationManagerDelegate {
  
    @Published var streamData: String = ""
    @Published var isConnected: Bool = false
    @Published var mountpoints: [Mountpoint] = []
    @Published var mountpoint: String = ""
    
    @Published var internalLocation: CLLocation?
    @Published var bluetoothLocation: CLLocation?
    
    @Published var receivedBluetoothData: Data?
    @Published var connectionStatus: String = "Disconnected"
    @Published var lastReceivedDataSize: Double = 0.0
    @Published var lastError: String?
  
   
   
    
    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    private var readBuffer = [UInt8](repeating: 0, count: 4096)
    private var bluetoothManager: BluetoothManager
    private var timer: Timer?
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    



    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        super.init()
        setupLocationManager()
        setupBluetoothObserver()
        
               bluetoothManager.$receivedData
                   .compactMap { $0 }
                   .sink { [weak self] data in
                       self?.handleReceivedBluetoothData(data)
                   }
                   .store(in: &cancellables)
           
        
    }
    
//    private func handleReceivedBluetoothData(_ data: Data) {
           // Traitez les données reçues ici
//           self.receivedBluetoothData = data
           // Vous pouvez également déclencher d'autres actions ou mises à jour ici
  //     }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupBluetoothObserver() {
          bluetoothManager.$receivedData
              .compactMap { $0 }
              .sink { [weak self] data in
                  self?.handleReceivedBluetoothData(data)
              }
              .store(in: &cancellables)
      }

    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        internalLocation = locations.last
    }

    private func handleReceivedBluetoothData(_ data: Data) {
        guard let nmeaString = String(data: data, encoding: .ascii) else { return }
        let sentences = nmeaString.components(separatedBy: .newlines)
        
        for sentence in sentences {
            if sentence.starts(with: "$GPGGA") || sentence.starts(with: "$GNGGA") {
                if let location = parseGGA(sentence) {
                    DispatchQueue.main.async {
                        self.bluetoothLocation = location
                    }
                }
            }
            // Vous pouvez ajouter d'autres types de phrases NMEA ici si nécessaire
        }
    }
    private func parseNMEA(_ nmeaString: String) -> CLLocation? {
        let sentences = nmeaString.components(separatedBy: .newlines)
        for sentence in sentences {
            if sentence.starts(with: "$GNGGA") {
                return parseGGA(sentence)
            }
        }
        return nil
    }

    private func parseGGA(_ sentence: String) -> CLLocation? {
        let components = sentence.components(separatedBy: ",")
        guard components.count >= 15 else { return nil }

        let latDegrees = Double(components[2].prefix(2)) ?? 0
        let latMinutes = Double(components[2].dropFirst(2)) ?? 0
        let latitude = latDegrees + (latMinutes / 60)
        let latDirection = components[3]

        let lonDegrees = Double(components[4].prefix(3)) ?? 0
        let lonMinutes = Double(components[4].dropFirst(3)) ?? 0
        let longitude = lonDegrees + (lonMinutes / 60)
        let lonDirection = components[5]

        let finalLatitude = latDirection == "S" ? -latitude : latitude
        let finalLongitude = lonDirection == "W" ? -longitude : longitude

        let altitude = Double(components[9]) ?? 0
        let timestamp = Date() // Idéalement, vous devriez extraire le temps du NMEA

        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: finalLatitude, longitude: finalLongitude),
                          altitude: altitude,
                          horizontalAccuracy: 0,
                          verticalAccuracy: 0,
                          timestamp: timestamp)
    }

    func refreshMountpoints(server: String, port: Int, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://\(server):\(port)") else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("NTRIP/2.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error refreshing mountpoints: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let data = data,
               let sourceTable = String(data: data, encoding: .ascii) ?? String(data: data, encoding: .isoLatin1) {
                print("Received source table: \(sourceTable)")
                let newMountpoints = self.parseMountpoints(from: sourceTable)
                
                DispatchQueue.main.async {
                    self.mountpoints = newMountpoints
                
                    if let userLocation = self.internalLocation {
                        for index in self.mountpoints.indices {
                            let mountpointLocation = CLLocationCoordinate2D(latitude: self.mountpoints[index].latitude, longitude: self.mountpoints[index].longitude)
                            self.mountpoints[index].distance = userLocation.distance(to: mountpointLocation) / 1000 // Convertir en km
                        }
                        self.mountpoints.sort { $0.distance ?? Double.infinity < $1.distance ?? Double.infinity }
                        
                        // Sélectionner automatiquement le point de montage le plus proche
                        DispatchQueue.main.async {
                            if let closestMountpoint = self.mountpoints.first {
                                self.mountpoint = closestMountpoint.name
                                print("Automatically selected closest mountpoint: \(closestMountpoint.name)")
                            
                               // Forcer la mise à jour de l'interface utilisateur
                                           DispatchQueue.main.async {
                                               // Cette ligne force SwiftUI à réévaluer la vue
                                               self.objectWillChange.send()
                                           }
                                
                            }
                         }
                    }
                    
                    self.objectWillChange.send()
                    completion(!self.mountpoints.isEmpty)
                }
            } else {
                print("Failed to decode source table or invalid response")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    private func parseMountpoints(from sourceTable: String) -> [Mountpoint] {
        return sourceTable.components(separatedBy: .newlines)
            .filter { $0.starts(with: "STR;") }
            .compactMap { line in
                let components = line.components(separatedBy: ";")
                guard components.count > 9 else { return nil }
                let name = components[1]
                guard let latitude = Double(components[9]),
                      let longitude = Double(components[10]) else { return nil }
                return Mountpoint(name: name, latitude: latitude, longitude: longitude)
                
                
            }
    }
    

    func connect(server: String, port: Int, mountpoint: String, username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard !isConnected else { return }
        
        DispatchQueue.main.async {
            self.connectionStatus = "Connecting..."
        }
        
        streamData = ""  // Réinitialiser streamData
        
        Stream.getStreamsToHost(withName: server, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        guard let input = inputStream, let output = outputStream else {
            DispatchQueue.main.async {
                self.connectionStatus = "Connection Failed"
            }
            completion(false)
            return
        }
        
        input.delegate = self
        output.delegate = self
        
        input.schedule(in: .current, forMode: .default)
        output.schedule(in: .current, forMode: .default)
        
        input.open()
        output.open()
        
        let credentials = "\(username):\(password)".data(using: .utf8)!.base64EncodedString()
        let request = "GET /\(mountpoint) HTTP/1.1\r\nHost: \(server)\r\nAuthorization: Basic \(credentials)\r\nUser-Agent: NTRIP SwiftClient/1.0\r\n\r\n"
        
        if let requestData = request.data(using: .utf8) {
            _ = requestData.withUnsafeBytes { output.write($0.bindMemory(to: UInt8.self).baseAddress!, maxLength: requestData.count) }
        }
        
        isConnected = true
        startSendingGGAData() // Démarre l'envoi périodique des données GGA
        
        DispatchQueue.main.async {
            self.connectionStatus = "Connected"
        }
        
        completion(true)
    }


    func disconnect() {
        guard isConnected else { return }
        
        stopSendingGGAData() // Arrête l'envoi périodique des données GGA
        
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
        isConnected = false
        streamData = ""
    
        DispatchQueue.main.async {
              self.connectionStatus = "Disconnected"
          }
    }
    
    
}

struct Mountpoint: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var distance: Double?
}

extension CLLocation {
    func distance(to location: CLLocationCoordinate2D) -> CLLocationDistance {
        return distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
    }
}



extension NTRIPClient: StreamDelegate {
  
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            if aStream == inputStream {
                readAvailableBytes(stream: aStream as! InputStream)
            }
        case .endEncountered:
            setError("Stream ended")
            DispatchQueue.main.async {
                self.connectionStatus = "Disconnected"
            }
            disconnect()
        case .errorOccurred:
            if let error = aStream.streamError {
                setError("Stream error: \(error.localizedDescription)")
            } else {
                setError("Unknown stream error occurred")
            }
            DispatchQueue.main.async {
                self.connectionStatus = "Error"
            }
            disconnect()
        case .openCompleted:
            DispatchQueue.main.async {
                self.connectionStatus = "Connected"
            }
        case .hasSpaceAvailable:
            // This is typically used for writing, but we're not using it here
            break
        default:
            setError("Unhandled stream event: \(eventCode)")
        }
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async {
            self.lastError = message
            self.objectWillChange.send()
        }
    }
    

    private func readAvailableBytes(stream: InputStream) {
        let bufferSize = 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = stream.read(&buffer, maxLength: bufferSize)
            
            if numberOfBytesRead < 0 {
                if let error = stream.streamError {
                    print("Error reading stream: \(error.localizedDescription)")
                }
                break
            }
            
            if numberOfBytesRead > 0 {
                let data = Data(bytes: buffer, count: numberOfBytesRead)
                DispatchQueue.main.async { [weak self] in
                    self?.processReceivedData(data)
                }
            }
        }
    }
    
    private func processReceivedData(_ data: Data) {
        let kbReceived = Double(data.count) / 1024.0
        print("Received data from NTRIP server: \(String(format: "%.2f", kbReceived)) KB")
        
        // Mettre à jour lastReceivedDataSize
         DispatchQueue.main.async {
             self.lastReceivedDataSize = kbReceived
         }
                
        bluetoothManager.sendData(data)
        print("Sending RTCM data to GNSS receiver: \(String(format: "%.2f", kbReceived)) KB")
    }
    
   private func generateGGA() -> String? {
        guard let location = self.bluetoothLocation else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmmss.SS"
        let timeString = dateFormatter.string(from: Date())
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let latDegrees = Int(abs(latitude))
        let latMinutes = (abs(latitude) - Double(latDegrees)) * 60
        let latDirection = latitude >= 0 ? "N" : "S"
        
        let lonDegrees = Int(abs(longitude))
        let lonMinutes = (abs(longitude) - Double(lonDegrees)) * 60
        let lonDirection = longitude >= 0 ? "E" : "W"
        
        let latString = String(format: "%02d%06.3f,%@", latDegrees, latMinutes, latDirection)
        let lonString = String(format: "%03d%06.3f,%@", lonDegrees, lonMinutes, lonDirection)
        
        let altitude = location.altitude
        let hdop = 1.0 // Vous devriez obtenir cette valeur du récepteur GNSS si possible
        let geoidSeparation = 0.0 // Vous devriez obtenir cette valeur du récepteur GNSS si possible
        let satellitesInUse = 8 // Vous devriez obtenir cette valeur du récepteur GNSS si possible
        
        let gga = String(format: "$GPGGA,%@,%@,%@,1,%02d,%.1f,%.1f,M,%.1f,M,,",
                         timeString,
                         latString,
                         lonString,
                         satellitesInUse,
                         hdop,
                         altitude,
                         geoidSeparation)
        
        let checksum = calculateNMEAChecksum(gga)
        return gga + "*" + checksum + "\r\n"
    }

    private func calculateNMEAChecksum(_ sentence: String) -> String {
        var checksum: UInt8 = 0
        for char in sentence.dropFirst() {
            if char == "*" { break }
            checksum ^= char.asciiValue ?? 0
        }
        return String(format: "%02X", checksum)
    }



    private func startSendingGGAData() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sendGGAData()
        }
    }

    private func sendGGAData() {
        guard let gga = generateGGA() else { return }
        sendToNTRIPServer(gga)
    }

    private func sendToNTRIPServer(_ message: String) {
        guard isConnected, let data = message.data(using: .ascii) else { return }
        outputStream?.write([UInt8](data), maxLength: data.count)
    }

    private func stopSendingGGAData() {
        timer?.invalidate()
        timer = nil
    }
    
    
}
