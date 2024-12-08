//
//  ContentView.swift
//  Client NTRIP
//
//  Created by francklin nguyen on 16/08/2024.
//

import SwiftUI
import SwiftData
import CoreLocation

class SharedSettings: ObservableObject {
    @Published var server: String = "caster.centipede.fr"
    @Published var port: String = "2101"
    @Published var username: String = "centipede"
    @Published var password: String = "centipede"
}


struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @StateObject private var ntripClient: NTRIPClient
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @StateObject private var sharedSettings = SharedSettings()
   
    init() {
        let bluetoothManager = BluetoothManager()
        _bluetoothManager = StateObject(wrappedValue: bluetoothManager)
        _ntripClient = StateObject(wrappedValue: NTRIPClient(bluetoothManager: bluetoothManager))
    }

    var body: some View {
        TabView {
            PositionView(bluetoothManager: bluetoothManager, ntripClient: ntripClient)
                .tabItem {
                    Label("Position", systemImage: "location")
                }

            
            SettingsView(bluetoothManager: bluetoothManager, ntripClient: ntripClient, modelContext: modelContext, items: items)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                 }
            
                .environmentObject(sharedSettings)
        }
        .onAppear {
            loadSavedData()
       
        }
 
    }

    
    private func loadSavedData() {
      
        
        if let savedItem = items.first {
            bluetoothManager.savedPeripheralUUID = savedItem.bluetoothPeripheralUUID
            $sharedSettings.server.wrappedValue = savedItem.server
            $sharedSettings.port.wrappedValue = savedItem.port
                    $ntripClient.mountpoint.wrappedValue = savedItem.mountpoint
            $sharedSettings.username.wrappedValue = savedItem.username
            $sharedSettings.password.wrappedValue = savedItem.password
        }
    }
}

struct PositionView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var ntripClient: NTRIPClient

    var body: some View {
        List {
            Section(header: Text("Internal iPhone Location")) {
                if let location = ntripClient.internalLocation {
                    Text("Lat: \(location.coordinate.latitude, specifier: "%.6f"), Lon: \(location.coordinate.longitude, specifier: "%.6f")")
                } else {
                    Text("Locating...")
                }
            }

            Section(header: Text("Bluetooth GNSS Location")) {
                if let location = bluetoothManager.bluetoothLocation {
                    Text("Lat: \(location.coordinate.latitude, specifier: "%.6f"), Lon: \(location.coordinate.longitude, specifier: "%.6f")")
                    Text("Satellites fix/view: \(bluetoothManager.satellitesUsed)/\(bluetoothManager.satelliteCount)")
                    Text("Fix Status: \(bluetoothManager.fixStatus)")
                    Text("Horizontal Accuracy: \(bluetoothManager.horizontalAccuracy, specifier: "%.2f") m")
                    Text("Vertical Accuracy: \(bluetoothManager.verticalAccuracy, specifier: "%.2f") m")
                    Text("Altitude: \(bluetoothManager.correctedAltitude, specifier: "%.2f") m")
                } else {
                    Text("Waiting for Bluetooth GNSS data...")
                }
            }

            if let error = bluetoothManager.lastError {
                Section(header: Text("Error")) {
                    Text(error)
                        .foregroundColor(.red)
                }
            }

            Section(header: Text("NTRIP Status")) {
                Text("NTRIP Status: \(ntripClient.mountpoint) \(ntripClient.connectionStatus)")
                Text("Bluetooth Status: \(bluetoothManager.fixStatus)")
                Text("Last RTCM data received: \(ntripClient.lastReceivedDataSize, specifier: "%.2f") KB")
                Text("Last RTCM data sent to GNSS: \(bluetoothManager.lastSentDataSize, specifier: "%.2f") KB")
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct SettingsView: View {
    @EnvironmentObject var sharedSettings: SharedSettings
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var ntripClient: NTRIPClient
    var modelContext: ModelContext
    var items: [Item]

    @State private var isShowingScanView = false
    @State private var showConnectionStatus = false
    @State private var connectionStatusMessage = ""
    @State private var showStatusMessage = false
    
    
    var body: some View {
        Form {
            Section(header: Text("Bluetooth")) {
                Button("Scan for Devices") {
                    isShowingScanView = true
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button("Bluetooth Connect") {
                    bluetoothManager.reconnectToSavedPeripheral()
                }
                .buttonStyle(BorderedButtonStyle())
                
                if let peripheral = bluetoothManager.connectedPeripheral {
                    Text("Connected to: \(peripheral.name ?? "Unknown Device")")
                } else {
                    Text("Not connected")
                }
            }
            
            Section(header: Text("NTRIP Configuration")) {
                TextField("Server", text: $sharedSettings.server)
                TextField("Port", text: $sharedSettings.port)
                    .keyboardType(.numberPad)
                
                Button("Refresh Mountpoints") {
                    refreshMountpoints()
                }
                .buttonStyle(BorderedButtonStyle())
                
                if ntripClient.mountpoints.isEmpty {
                    TextField("Mountpoint", text: $ntripClient.mountpoint)
                } else {
                    Picker("Mountpoint", selection: $ntripClient.mountpoint) {
                        ForEach(ntripClient.mountpoints, id: \.name) { mountpoint in
                            Text("\(mountpoint.name) (\(String(format: "%.2f", mountpoint.distance ?? 0)) km)")
                                .tag(mountpoint.name)
                        }
                    }
                }
                
                TextField("Username", text: $sharedSettings.username)
                SecureField("Password", text: $sharedSettings.password)
                
                Button(action: toggleConnection) {
                    Text(ntripClient.isConnected ? "Disconnect Mountpoint" : "Connect Mountpoint")
                }
                .buttonStyle(BorderedButtonStyle())
            }
            
            Button("Save Parameters") {
                saveParameters()
            }
            .buttonStyle(BorderedButtonStyle())
            
          
            if showStatusMessage {
                           Text(connectionStatusMessage)
                              // .foregroundColor(connectionStatusMessage.contains("Successfully") ? .green : .red)
                               .padding()
                               .background(Color.gray.opacity(0.1))
                               .cornerRadius(8)
                       }
            
        }
        .sheet(isPresented: $isShowingScanView) {
            ScanView(bluetoothManager: bluetoothManager)
        }
    }

    private func saveParameters() {
        if items.isEmpty {
            let newItem = Item(
                bluetoothPeripheralUUID: bluetoothManager.connectedPeripheral?.identifier,
                server: sharedSettings.server,
                port: sharedSettings.port,
                mountpoint: ntripClient.mountpoint,
                username: sharedSettings.username,
                password: sharedSettings.password
            )
            modelContext.insert(newItem)
        } else if let existingItem = items.first {
            existingItem.bluetoothPeripheralUUID = bluetoothManager.connectedPeripheral?.identifier
            existingItem.server = sharedSettings.server
            existingItem.port = sharedSettings.port
            existingItem.mountpoint = ntripClient.mountpoint
            existingItem.username = sharedSettings.username
            existingItem.password = sharedSettings.password
        }

        do {
            try modelContext.save()
            connectionStatusMessage = "Parameters saved successfully"
            showStatusMessage = true
        } catch {
            connectionStatusMessage = "Error saving parameters: \(error.localizedDescription)"
            showStatusMessage = true
        }
    }

    private func refreshMountpoints() {
        guard let portNumber = Int(sharedSettings.port), portNumber > 0 && portNumber <= 65535 else {
            connectionStatusMessage = "Invalid port number"
            showStatusMessage = true
            return
        }

        ntripClient.refreshMountpoints(server: sharedSettings.server, port: portNumber) { success in
            if success {
                connectionStatusMessage = "Mountpoints refreshed successfully"
            } else {
                connectionStatusMessage = "Failed to refresh mountpoints"
            }
            showStatusMessage = true
        }
    }

    private func toggleConnection() {
        if ntripClient.isConnected {
            ntripClient.disconnect()
            connectionStatusMessage = "Disconnected from NTRIP server"
        } else {
            guard let portNumber = Int(sharedSettings.port) else {
                connectionStatusMessage = "Invalid port number"
                showStatusMessage = true
                return
            }

            ntripClient.connect(server: sharedSettings.server, port: portNumber, mountpoint: ntripClient.mountpoint, username: sharedSettings.username, password: sharedSettings.password) { success in
                if success {
                    connectionStatusMessage = "Successfully connected to NTRIP server"
                } else {
                    connectionStatusMessage = "Failed to connect to NTRIP server"
                }
            }
        }
        showStatusMessage = true
    }
}

struct ScanView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
            Button(action: {
                bluetoothManager.connect(to: peripheral)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text(peripheral.name ?? "Unknown Device")
            }
        }
        .onAppear {
            bluetoothManager.startScanning()
        }
        .onDisappear {
            bluetoothManager.stopScanning()
        }
    }
}

