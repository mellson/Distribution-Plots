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
        socketSync.startServer(finish)
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
        socketSync.startServer(finish)
    }
    
    @IBAction func startClient(sender: NSButton) {
        socketSync.startClient(setTime, measurementType: UdpMessageType.OffsetMeasurement)
    }
    
    @IBAction func startDelayMeasurements(sender: NSButton) {
        socketSync.startClient(setTime, measurementType: UdpMessageType.DelayMeasurement)
    }
    
    func shell(launchPath: String, arguments: [AnyObject])
    {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        task.launch()
        task.waitUntilExit()
    }
    
    func finish(result: String) {
        let path = "result.txt"
        result.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        let bundle = NSBundle.mainBundle()
        var scriptPath: String?
        if MeasurementType == UdpMessageType.DelayMeasurement {
            scriptPath = bundle.pathForResource("RdelayScript", ofType: "txt")
        } else {
            scriptPath = bundle.pathForResource("RoffsetScript", ofType: "txt")
        }
        shell("/usr/bin/R", arguments: ["CMD", "BATCH", scriptPath!])
        
        // Give the plot a unique file name
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hhmmss dd-MM-yyyy"
        let date = dateFormatter.stringFromDate(NSDate())
        let plotName = "Plot \(date).pdf"
        shell("/bin/mv", arguments: ["Rplots.pdf", plotName])
        shell("/usr/bin/open", arguments: [plotName])
    }
}

