//
//  ViewController.swift
//  Socket-Sync-Mac
//
//  Created by Anders Bech Mellson on 06/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Cocoa

class MacViewController: NSViewController {
    var socketSync = SocketSync()
    @IBOutlet var ipTextField: NSTextField!
    @IBOutlet var timeLabel: NSTextField!
    
    func setTime(string: String) {
        timeLabel.stringValue = string
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipTextField.stringValue = SERVER_IP
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func changeIP(sender: NSTextField) {
        SERVER_IP = sender.stringValue
    }
    
    @IBAction func startServer(sender: NSButton) {
        socketSync.startServer()
    }
    
    @IBAction func startClient(sender: NSButton) {
        socketSync.startClient(setTime, measurementType: UdpMessageType.OffsetMeasurement)
    }
    
    @IBAction func startDelayMeasurements(sender: NSButton) {
        socketSync.startClient(setTime, measurementType: UdpMessageType.DelayMeasurement)
    }
}

