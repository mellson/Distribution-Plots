//
//  Broadcaster.swift
//  Socket-Sync
//
//  Created by Anders Bech Mellson on 16/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

class MulticastServer: NSObject, GCDAsyncUdpSocketDelegate {
    var multicast_socket:GCDAsyncUdpSocket!
    var client_socket:GCDAsyncUdpSocket!
    var error : NSError?
    var timer: NSTimer?
    let finishFunction: String -> ()
    
    var connectedClients: [String: String] = [:]
    
    init(finishFunction: String -> ()){
        self.finishFunction = finishFunction
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        multicast_socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//        multicast_socket.enableBroadcast(true, error: &error)
        multicast_socket.setMaxReceiveIPv4BufferSize(65535)
        multicast_socket.setMaxReceiveIPv6BufferSize(4294967295)
        multicast_socket.bindToPort(SERVER_PORT, error: &error)
        multicast_socket.beginReceiving(&error)
        println("Multicast server started at \(SERVER_IP)")
        
        timer = NSTimer.scheduledTimerWithTimeInterval(MeasurementInterval, target: self, selector: Selector("broadcastMessage"), userInfo: nil, repeats: true)
    }
    
    var tag = 0
    func broadcastMessage() {
        var t1: NSData = dataSync(getCurrentTimeSince1970())
        multicast_socket.sendData(t1, toHost: MULTICAST_GROUP, port: MULTICAST_PORT, withTimeout: -1, tag: tag++)
    }
    
    func getCurrentTimeSince1970() -> NSTimeInterval {
        let now = NSDate()
        return now.timeIntervalSince1970
    }
    
    var counter = 1
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let msg = udpMessageFromData(data)
        
        let addressOfSender = GCDAsyncUdpSocket.hostFromAddress(address)
        let portOfSender = GCDAsyncUdpSocket.portFromAddress(address)
        
        if let name = connectedClients[addressOfSender] {
        } else {
            connectedClients[addressOfSender] = "Client with port \(portOfSender)"
        }
        
        if msg.type == UdpMessageType.OffsetMeasurement || msg.type == UdpMessageType.DelayMeasurement {
            MeasurementType = msg.type
            println("set type \(msg.type.rawValue)")
        }
        
        // Client is calculation network delay
        if msg.type == UdpMessageType.DelayRequest {
            client_socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            client_socket.connectToHost(addressOfSender, onPort: MULTICAST_PORT, error: &error)
            let t4 = delayReply(getCurrentTimeSince1970())
            client_socket.sendData(t4, withTimeout: -1, tag: 10)
            client_socket.closeAfterSending()
            println("Message \(counter++) of \(NumberOfMeasurements)")
        }

        if msg.type == UdpMessageType.MeasurementResult {
//            timer?.invalidate()
            counter = 1
            println("Finished")
            finishFunction(msg.msg)
        }
    }
}