//
//  StopWatch.swift
//  Socket-Sync
//
//  Created by Anders Bech Mellson on 23/03/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation

class StopWatch {
    private var s_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    private let kOneMillion: UInt64 = 1000 * 1000
    
    init() {
        if (s_timebase_info.denom == 0) {
            mach_timebase_info(&s_timebase_info)
        }
    }
    
    private var startTime: UInt64 = 0
    func start() {
        startTime = mach_absolute_time()
    }
    
    private var stopTime: UInt64 = 0
    func stop() {
        stopTime = mach_absolute_time()
    }
    
    func getTimeElapsedNs() -> UInt64 {
        return (((stopTime - startTime) * UInt64(s_timebase_info.numer))) / UInt64(s_timebase_info.denom)
    }
    
    func getTimeElapsedMs() -> UInt64 {
        return (((stopTime - startTime) * UInt64(s_timebase_info.numer))) / (kOneMillion * UInt64(s_timebase_info.denom))
    }
}