//
//  ViewController.swift
//  Socket-Sync
//
//  Created by Anders Bech Mellson on 06/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import UIKit

class iOSViewController: UIViewController {
    var socketSync = SocketSync()
    
    @IBOutlet var ipTextField: UITextField!
    @IBOutlet var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipTextField.text = SERVER_IP
        
        // Turn off sleep mode
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    func setLabel(string: String) {
        timeLabel.text = string
    }

    @IBAction func finishedEditingIP(sender: UITextField) {
        SERVER_IP = sender.text
        sender.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func startServer() {
        socketSync.startServer()
    }
    
    @IBAction func startClient() {
        socketSync.startClient(setLabel, measurementType: UdpMessageType.OffsetMeasurement)
    }

    
    @IBAction func startDelayMeasurement() {
        socketSync.startClient(setLabel, measurementType: UdpMessageType.DelayMeasurement)
    }
}

