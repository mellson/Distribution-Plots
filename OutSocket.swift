//
//  OutSocket.swift
//  Socket-Prototype
//
//  Created by Anders Bech Mellson on 05/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

class OutSocket: NSObject, GCDAsyncUdpSocketDelegate {
    var socket:GCDAsyncUdpSocket!
    let clicker = Clicker()
    
    override init(){
        super.init()
        setupConnection()
    }
    
    func setupConnection(){
        var error : NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        socket.bindToPort(CLIENT_PORT, error: &error)
        socket.connectToHost(SERVER_IP, onPort: SERVER_PORT, error: &error)
        socket.beginReceiving(&error)
    }
    
    func send(message:String){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        socket.sendData(data, withTimeout: 2, tag: 0)
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didConnectToAddress address: NSData!) {
        let address = GCDAsyncUdpSocket.hostFromAddress(address)
        println("Client Connected To Server \(address)");
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotConnect error: NSError!) {
        println("didNotConnect \(error)")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didSendDataWithTag tag: Int) {
//        println("didSendDataWithTag")
    }
    
    func udpSocket(sock: GCDAsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        println("didNotSendDataWithTag")
    }
    
    var measurement = 1
    func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!, fromAddress address: NSData!, withFilterContext filterContext: AnyObject!) {
        let strData = data.subdataWithRange(NSMakeRange(0, data.length))
        let msg = NSString(data: strData, encoding: NSUTF8StringEncoding)
        
        // Insert delay
//        mach_wait_until(upTime() + 100000000)
        println(msg)
        if msg!.containsString("Sync Message") && measurement <= 10 {
            send("Sync Ack \(measurement++)")
        } else {
            if msg!.containsString("Play") {
                let offset = UInt64(msg!.substringFromIndex(4).toInt()!)
                playClick1(mach_absolute_time() + (playTime() - offset))
            } else {
                send("Hello from client")
            }
        }
    }
    
    func playClick1(atTime:UInt64) {
        dispatch_async(dispatch_get_global_queue( QOS_CLASS_USER_INTERACTIVE, 0), {
            mach_wait_until(atTime)
            self.clicker.click1()
            self.send("X")
        })
    }


}