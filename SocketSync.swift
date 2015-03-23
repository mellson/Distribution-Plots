//
//  ViewController.swift
//  Socket-Prototype
//
//  Created by Anders Bech Mellson on 05/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

class SocketSync: NSObject {
    var multicastServer: MulticastServer!
    var multicastClient: MulticastClient!
    var inSocket: InSocket!
    var outSocket: OutSocket!
    
    func startServer() {
        multicastServer = MulticastServer()
    }

    func startDelayMeasurements(updateTime: String -> (), measurementType: UdpMessageType) {
        multicastClient = MulticastClient(updateTime: updateTime, measurementType: measurementType)
    }
    
    func startClient(updateTime: String -> (), measurementType: UdpMessageType) {
        multicastClient = MulticastClient(updateTime: updateTime, measurementType: measurementType)
    }
    
    func stopMeasurement() {
        multicastClient.stopMeasurementsAndSendResults()
    }
}