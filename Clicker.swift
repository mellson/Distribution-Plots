//
//  Clicker.swift
//  Socket-Prototype
//
//  Created by Anders Bech Mellson on 06/02/15.
//  Copyright (c) 2015 dk.mellson. All rights reserved.
//

import Foundation
import AVFoundation

class Clicker {
    private let av1: AVAudioPlayer?
    private let av2: AVAudioPlayer?
    
    init() {
        let soundUrl1 = NSBundle.mainBundle().URLForResource("Click1", withExtension: "aif")
        let soundUrl2 = NSBundle.mainBundle().URLForResource("Click2", withExtension: "aif")
        var error: NSError?
        av1 = AVAudioPlayer(contentsOfURL: soundUrl1, error: &error)
        av2 = AVAudioPlayer(contentsOfURL: soundUrl2, error: &error)
        prepare()
    }
    
    func prepare() {
        av1!.prepareToPlay()
        av2!.prepareToPlay()
    }
    
    func click1() {
        av1!.play()
    }
    
    func click2() {
        av2!.play()
    }
}