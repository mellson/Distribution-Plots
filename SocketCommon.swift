//
//  SocketCommon.swift
//  Socket-Prototype
//
//  Created by Anders Bech Mellson on 06/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

let MULTICAST_GROUP = "224.0.20.15" // The multicast range is 224.0.0.0 to 239.255.255.255

var SERVER_IP = "192.168.1.3"
let SERVER_PORT:UInt16 = 7000

let CLIENT_IP = "localhost"
let CLIENT_PORT:UInt16 = 7001

let MULTICAST_PORT:UInt16 = 7002

let MeasurementInterval = 0.1
let NumberOfMeasurements = 100
var MeasurementType = UdpMessageType.OffsetMeasurement

var s_timebase_info = mach_timebase_info(numer: 0, denom: 0)
let kOneMillion: UInt64 = 1000 * 1000
func uptimeInMilliseconds() -> UInt64 {
    if (s_timebase_info.denom == 0) {
        mach_timebase_info(&s_timebase_info)
        println("Denom \(s_timebase_info.denom) Numer \(s_timebase_info.numer)")
    }
    return ((mach_absolute_time() * UInt64(s_timebase_info.numer))) / (kOneMillion * UInt64(s_timebase_info.denom))
}

func playTime() -> UInt64 {
    var info = mach_timebase_info(numer: 0, denom: 0)
    if (info.denom == 0) {
        mach_timebase_info(&info)
        println("Denom \(info.denom) Numer \(info.numer)")
    }
    let second: UInt32 = 1000000000
    let correctedSecond = second * info.denom / info.numer
    return UInt64(correctedSecond)
}

func shell(launchPath: String, arguments: [AnyObject])
{
    let task = NSTask()
    task.launchPath = launchPath
    task.arguments = arguments
    task.launch()
    task.waitUntilExit()
}