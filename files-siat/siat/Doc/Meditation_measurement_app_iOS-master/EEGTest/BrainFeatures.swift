//
//  BrainFeatures.swift
//  EEGTest
//
//  Created by Simiao Yu on 13/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit

class BrainFeatures: NSObject {
    func CalcMeditationScore(BrainSpectrumPower: SpectrumPower) -> Float {

        var alphaL = BrainSpectrumPower.alphaL
        var theta = BrainSpectrumPower.theta
        
        var ratio: Float = Float(alphaL / theta)
        var upperLimit: Float = 1.3
        var lowerLimit: Float = 0.8
        
        var meditationScore = (ratio - lowerLimit) / (upperLimit - lowerLimit)
        
        if meditationScore > 1 {
            return 1
        }
        else if meditationScore < 0 {
            return 0
        }
        else {
            return meditationScore
        }
        
    }
}
