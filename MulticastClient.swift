//
//  MulticastClient.swift
//  Socket-Sync
//
//  Created by Anders Bech Mellson on 16/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

class MulticastClient: NSObject, GCDAsyncUdpSocketDelegate {
    var multicast_socket:GCDAsyncUdpSocket!
    var phonehome_socket:GCDAsyncUdpSocket!
    var error : NSError?
    let clicker = Clicker()
    let timeUpdater: String -> ()
    
    init(updateTime: String -> (), measurementType: UdpMessageType){
        timeUpdater = updateTime
        super.init()
        setupConnection()
        MeasurementType = measurementType
    }
    
    func setupConnection(){
        multicast_socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        multicast_socket.bindToPort(MULTICAST_PORT, error: &error)
        multicast_socket.joinMulticastGroup(MULTICAST_GROUP, error: &error)
        multicast_socket.beginReceiving(&error)
        println("Multicast client started")
    }
    
    var resultValuesMilliseconds: [NSTimeInterval] = []
    var offset: NSTimeInterval = 0
    var t3: NSTimeInterval = 0
    var delayReqTime: NSDate?
    var calculateOffset1 = true
    var calculateOffset2 = false
    var connected = false
    var stopCalculating = false
    var counter = 0
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let msg = udpMessageFromData(data)
        
        if !connected {
            let addressOfSender = GCDAsyncUdpSocket.hostFromAddress(address)
            let portOfSender = GCDAsyncUdpSocket.portFromAddress(address)
            phonehome_socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            phonehome_socket.bindToPort(CLIENT_PORT, error: &error)
            phonehome_socket.beginReceiving(&error)
            phonehome_socket.connectToHost(addressOfSender, onPort: portOfSender, error: &error)
            phonehome_socket.sendData(measurementType(MeasurementType), withTimeout: -1, tag: 0)
            connected = true
        }
        
        if calculateOffset1 && msg.type == UdpMessageType.Sync && !stopCalculating {
            if MeasurementType == UdpMessageType.OffsetMeasurement {
                let t1 = msg.time
                let t2 = NSDate()
                offset = t1 - t2.timeIntervalSince1970
                t3 = NSDate(timeIntervalSinceNow: offset).timeIntervalSince1970
            } else {
                delayReqTime = NSDate()
            }
            phonehome_socket.sendData(delayReq(), withTimeout: -1, tag: 0)
            calculateOffset1 = false
            calculateOffset2 = true
        }
        
        if calculateOffset2 && msg.type == UdpMessageType.DelayReply {
            calculateOffset1 = true
            calculateOffset2 = false
            if MeasurementType == UdpMessageType.OffsetMeasurement {
                let t4 = msg.time
                let t5 = NSDate()
                offset = ((t5.timeIntervalSince1970-t3) / 2) - (t5.timeIntervalSince1970 - t4)
                resultValuesMilliseconds.append(offset * 1000)
            } else {
                let delayTime = NSDate().timeIntervalSinceDate(delayReqTime!)
                resultValuesMilliseconds.append(delayTime * 1000) // Convert offset from seconds to ms
            }
            counter++
            if counter == NumberOfMeasurements {
                stopMeasurementsAndSendResults()
            }
        }
        
        if msg.type == UdpMessageType.Blip {
            println("blip \(msg.time)")
        }
    }
    
    func stopMeasurementsAndSendResults() {
        stopCalculating = true
        let sortedResults = sorted(resultValuesMilliseconds)
        var output = ""
        for value in sortedResults {
            output += "\(value)\n"
        }
        let data = measurementResult(output)
        phonehome_socket.sendData(data, withTimeout: -1, tag: 0)
        multicast_socket.close()
        phonehome_socket.closeAfterSending()
        resultValuesMilliseconds = []
    }
    
    func click() {
        clicker.click1()
    }
}