//
//  Item.swift
//  Client NTRIP
//
//  Created by francklin nguyen on 16/08/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
 //   var timestamp: Date
 //   var name: String
 //   var latitude: Double
 //   var longitude: Double
    var bluetoothPeripheralUUID: UUID?
    var server: String
    var port: String
    var mountpoint: String
    var username: String
    var password: String

    init(
      //  timestamp: Date = Date(),
      //   name: String = "",
      //   latitude: Double = 0.0,
      //   longitude: Double = 0.0,
         bluetoothPeripheralUUID: UUID? = nil,
         server: String = "",
         port: String = "",
         mountpoint: String = "",
         username: String = "",
         password: String = "") {
    //    self.timestamp = timestamp
    //    self.name = name
    //    self.latitude = latitude
    //    self.longitude = longitude
        self.bluetoothPeripheralUUID = bluetoothPeripheralUUID
        self.server = server
        self.port = port
        self.mountpoint = mountpoint
        self.username = username
        self.password = password
    }
}
