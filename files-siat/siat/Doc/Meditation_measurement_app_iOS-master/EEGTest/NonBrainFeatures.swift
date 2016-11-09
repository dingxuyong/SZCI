//
//  NonBrainFeatures.swift
//  EEGTest
//
//  Created by Simiao Yu on 12/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit

class NonBrainFeatures: NSObject {
    let BlinkThreshold = 70
    let ToothThreshold = 70
    let QualityThreshold = 70
    
    var BlinkScore: Int = 0
    var ToothScore: Int = 0
    
    var Blink: Bool = false
    var Tooth: Bool = false
    var Quality: Bool = false
    
    let QualityLowerBoundary: Int = 20
    let QualityUpperBoundary: Int = 600
    
    func CalcQuality (parsedData: [UInt32]) {
        let average = Average(parsedData)
        let sd = StandardDeviation(parsedData, average)
        let QualityScore = Int(floor(sd))
        Quality = QualityScore >= QualityLowerBoundary && QualityScore <= QualityUpperBoundary
    }
    
    func CalcFeatureScores (sP: SpectrumPower) {
        var scoreNormal = -17.9149
        scoreNormal += +0.1987 * sP.delta
        scoreNormal += -0.4639 * sP.theta
        scoreNormal += -0.1601 * sP.alphaL
        scoreNormal += -0.1811 * sP.alphaH
        scoreNormal += +0.8005 * sP.betaL
        scoreNormal += +0.7498 * sP.betaH
        scoreNormal += +0.3749 * sP.gammaL
        scoreNormal += +0.3092 * sP.gammaH;
        
        var scoreBlink = -23.0036
        scoreBlink += +0.2083 * sP.delta
        scoreBlink += -0.2643 * sP.theta
        scoreBlink += -0.0345 * sP.alphaL
        scoreBlink += -0.1390 * sP.alphaH
        scoreBlink += +0.4766 * sP.betaL
        scoreBlink += +0.4311 * sP.betaH
        scoreBlink += +0.1032 * sP.gammaL
        scoreBlink += +0.1315 * sP.gammaH;
        
        var scoreChew = -42.7107
        scoreChew += +0.1636 * sP.delta
        scoreChew += -0.4208 * sP.theta
        scoreChew += +0.2048 * sP.alphaL
        scoreChew += -0.6173 * sP.alphaH
        scoreChew += +2.1115 * sP.betaL
        scoreChew += +1.5450 * sP.betaH
        scoreChew += +2.3192 * sP.gammaL
        scoreChew += +1.5479 * sP.gammaH;
        
        if scoreBlink > scoreNormal && scoreBlink > scoreChew {
            Blink = true;
            Tooth = false;
        }
            
        else if scoreChew > scoreNormal && scoreChew > scoreBlink {
            Blink = false;
            Tooth = true;
        }
            
        else {
            Blink = false;
            Tooth = false;
        }
    }
    
    func Average (array: [UInt32]) -> Float {
        var sum: UInt32 = 0
        var startIndex = array.count - WIN_SIZE_FREQ_COMP

        for var i = startIndex; i < array.count; ++i {
            sum += array[i]
        }
        return Float(sum) / Float(WIN_SIZE_FREQ_COMP)
    }
    
    func StandardDeviation(array: [UInt32],_ average: Float) -> Float {
        var sum: Float = 0
        var startIndex = array.count - WIN_SIZE_FREQ_COMP
        
        for var i = startIndex; i < array.count; ++i {
            var floatItem = Float(array[i])
            sum += (floatItem - average) * (floatItem - average)
        }
        return sqrt(sum / Float(WIN_SIZE_FREQ_COMP))
    }
}








