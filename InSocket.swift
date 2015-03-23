//
//  InSocket.swift
//  Socket-Prototype
//
//  Created by Anders Bech Mellson on 05/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

class InSocket: NSObject, GCDAsyncUdpSocketDelegate {
    var socket:GCDAsyncUdpSocket!
    var error : NSError?
    let clicker = Clicker()
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.bindToPort(SERVER_PORT, error: &error)
        socket.beginReceiving(&error)
        println("Server started at \(SERVER_IP)")
    }
    
    var connected = false
    var measurement = 1
    var syncing = true
    var sendTime: UInt64 = 0
    var offset: UInt64 = 0
    var lastPlayTime: UInt64 = 0
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let strData = data.subdataWithRange(NSMakeRange(0, data.length))
        let msg = NSString(data: strData, encoding: NSUTF8StringEncoding)!
        
        if !connected {
            let addressOfSender = GCDAsyncUdpSocket.hostFromAddress(address)
            let portOfSender = GCDAsyncUdpSocket.portFromAddress(address)
            socket.connectToHost(addressOfSender, onPort: portOfSender, error: &error)
            connected = true
        }
        
//        println(msg)
        if measurement <= 10 {
            if msg.containsString("Sync Ack") {
                let now = mach_absolute_time()
                let currentOffset = now - sendTime
                offsetArray += [currentOffset]
            }
            let message = "Sync Message \(measurement++)"
            let returnMsg = message.dataUsingEncoding(NSUTF8StringEncoding)
            sendTime = mach_absolute_time()
            socket.sendData(returnMsg, withTimeout: 2, tag: 0)
        } else if measurement == 11 && syncing {
            var offSetSum = offsetArray.reduce(0,combine: +)
            offset = offSetSum / UInt64(offsetArray.count)
            offset = offset / 2 // Divide by two because of the roundtrip
            let message = "Finished Calculating Offset"
            let returnMsg = message.dataUsingEncoding(NSUTF8StringEncoding)
            socket.sendData(returnMsg, withTimeout: 2, tag: 0)
            syncing = false
            println("The offset is \(offset)")
        } else {
            //calcOffset()
            let message = "Play\(offset)"
            let offsetMsg = message.dataUsingEncoding(NSUTF8StringEncoding)
            
//            if mach_absolute_time() < lastPlayTime {
//                println("waiting")
//                mach_wait_until(lastPlayTime)
//            }
            
            print(".")
            lastPlayTime = mach_absolute_time() + playTime()
            playClick1(lastPlayTime)
            sendTime = mach_absolute_time()
            socket.sendData(offsetMsg, withTimeout: 2, tag: 0)
        }
    }
    
    var index = 0
    var numberOfCalculations = 10
    var offsetArray: [UInt64] = []
    func calcOffset() {
        let now = mach_absolute_time()
        let currentOffset = now - sendTime
        
        if (index+1) > offsetArray.count {
            offsetArray += [currentOffset]
        } else {
            offsetArray[index] = currentOffset
            println(offsetArray)
        }
        index = (index + 1) % numberOfCalculations
        var offSetSum = offsetArray.reduce(0,combine: +)
        offset = offSetSum / UInt64(offsetArray.count)
    }
    
    func playClick1(atTime:UInt64) {
        dispatch_async(dispatch_get_global_queue( QOS_CLASS_USER_INTERACTIVE, 0), {
            mach_wait_until(atTime)
            self.clicker.click1()
        })
    }
}