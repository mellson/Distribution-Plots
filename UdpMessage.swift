//
//  UdpMessage.swift
//  Socket-Sync
//
//  Created by Anders Bech Mellson on 19/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

enum UdpMessageType: Int {
    case Blip
    case Sync
    case DelayRequest
    case DelayReply
    case MeasurementResult
    case DelayMeasurement
    case OffsetMeasurement
    
    var description : String {
        switch self {
        case .Blip: return "Blip"
        case .Sync: return "Sync"
        case .DelayRequest: return "DelayRequest"
        case .DelayReply: return "DelayReply"
        case .MeasurementResult: return "MeasurementResult"
        case .DelayMeasurement: return "DelayMeasurement"
        case .OffsetMeasurement: return "OffsetMeasurement"
        }
    }
}

/** @objc(XRObjectAllocRun) added to make the fully qualified classname of UdpMessage
 *  be the same across iOS and OS X.
 *  http://stackoverflow.com/questions/27974959/how-to-change-the-namespace-of-a-swift-class
**/
@objc(XRObjectAllocRun) class UdpMessage : NSObject, NSCoding
{
    let type: UdpMessageType
    let time: Double
    let msg: String
    
    init(type: UdpMessageType, time: Double, msg: String){
        self.type = type;
        self.time = time;
        self.msg = msg;
    }
    
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeInteger(type.rawValue, forKey: "type")
        aCoder.encodeDouble(time, forKey: "time")
        aCoder.encodeObject(msg, forKey: "msg")
    }
    
    required init(coder aDecoder: NSCoder){
        self.type = UdpMessageType(rawValue: aDecoder.decodeIntegerForKey("type"))!
        self.time = aDecoder.decodeDoubleForKey("time")
        self.msg = aDecoder.decodeObjectForKey("msg") as! String
        super.init()
    }
}

func dataFromUdpMessage(var msg: UdpMessage) -> NSData {
    return NSKeyedArchiver.archivedDataWithRootObject(msg)
}

func udpMessageFromData(data: NSData) -> UdpMessage {
    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as! UdpMessage
}

func dataBlip(time: Double) -> NSData {
    return dataFromUdpMessage(UdpMessage(type: UdpMessageType.Blip, time: time, msg: ""))
}

func dataSync(time: Double) -> NSData {
    return dataFromUdpMessage(UdpMessage(type: UdpMessageType.Sync, time: time, msg: ""))
}

func delayReq() -> NSData {
    return dataFromUdpMessage(UdpMessage(type: UdpMessageType.DelayRequest, time: 0, msg: ""))
}

func delayReply(time: Double) -> NSData {
    return dataFromUdpMessage(UdpMessage(type: UdpMessageType.DelayReply, time: time, msg: ""))
}

func measurementResult(result: String) -> NSData {
    return dataFromUdpMessage(UdpMessage(type: UdpMessageType.MeasurementResult, time: 0, msg:result))
}

func measurementType(type: UdpMessageType) -> NSData {
    return dataFromUdpMessage(UdpMessage(type: type, time: 0, msg:""))
}