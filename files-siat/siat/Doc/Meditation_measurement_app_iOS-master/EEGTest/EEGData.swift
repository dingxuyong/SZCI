//
//  EEGData.swift
//  EEGTest
//
//  Created by Simiao Yu on 11/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit

class EEGData: NSObject {
    var DeltaPow: Double = 0
    var ThetaPow: Double = 0
    var AlphaPowLow: Double = 0
    var AlphaPowHi: Double = 0
    var BetaPowLow: Double = 0
    var BetaPowHi: Double = 0
    var GammaPowLow: Double = 0
    var GammaPowHi: Double = 0
    
    var Blink = false
    var Tooth = false
    var Quality = false
    
    var NonBrainFeature = NonBrainFeatures()
    var NonBrainSpectrumPower = SpectrumPower(appliedWindowSize: WIN_SIZE_FREQ_COMP)
    
    var BrainFeature = BrainFeatures()
    var BrainSpectrumPower = SpectrumPower(appliedWindowSize: WIN_SIZE_BRAIN_FEATURE)
    var MeditationScore: Float = 0
    
    func UpdateNonBrainFeature(parsedData: [UInt32]) {
        NonBrainSpectrumPower.CalcPowerSpectrum(parsedData)
        DeltaPow = NonBrainSpectrumPower.delta
        ThetaPow = NonBrainSpectrumPower.theta
        AlphaPowLow = NonBrainSpectrumPower.alphaL
        AlphaPowHi = NonBrainSpectrumPower.alphaH
        BetaPowLow = NonBrainSpectrumPower.betaL
        BetaPowHi = NonBrainSpectrumPower.betaH
        GammaPowLow = NonBrainSpectrumPower.gammaL
        GammaPowHi = NonBrainSpectrumPower.gammaH
        
        NonBrainFeature.CalcQuality(parsedData)
        Quality = NonBrainFeature.Quality
        
        if Quality {
            NonBrainFeature.CalcFeatureScores(NonBrainSpectrumPower)
            Blink = NonBrainFeature.Blink
            Tooth = NonBrainFeature.Tooth
        }
        else {
            Blink = false
            Tooth = false
        }
    }
    
    func ValidData () -> Bool {
        return (!Blink) && (!Tooth) && Quality
    }
    
    func UpdateBrainFeature(parsedData: [UInt32]) {
        BrainSpectrumPower.CalcPowerSpectrum(parsedData)
        MeditationScore =  BrainFeature.CalcMeditationScore(BrainSpectrumPower)
    }
}
