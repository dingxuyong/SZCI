//
//  SpectrumPower.swift
//  EEGTest
//
//  Created by Simiao Yu on 12/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit
import Accelerate

class SpectrumPower: NSObject {
    private var fftSetup: FFTSetup
    
    private let NHz: Int = 50
    private let Fs: Int = 512
    
    let DeltaLower: Int = 1 
    let DeltaUpper: Int = 4 
    let ThetaLower: Int = 4 
    let ThetaUpper: Int = 7 
    let AlphaLLower: Int = 7 
    let AlphaLUpper: Int = 10 
    let AlphaHLower: Int = 10 
    let AlphaHUpper: Int = 13 
    let BetaLLower: Int = 13 
    let BetaLUpper: Int = 18 
    let BetaHLower: Int = 18 
    let BetaHUpper: Int = 30 
    let GammaLLower: Int = 30 
    let GammaLUpper: Int = 40 
    let GammaHLower: Int = 40 
    let GammaHUpper: Int = 50
    
    private var dataArray: [Double]
    private var timeInterval: Double
    private var windowSize: Int
    
    var alphaH: Double = 0
    var alphaHNorm: Double = 0
    var alphaL: Double = 0
    var alphaLNorm: Double = 0
    var betaH: Double = 0
    var betaHNorm: Double = 0
    var betaL: Double = 0
    var betaLNorm: Double = 0
    var delta: Double = 0
    var deltaNorm: Double = 0
    var gammaH: Double = 0
    var gammaHNorm: Double = 0
    var gammaL: Double = 0
    var gammaLNorm: Double = 0
    var theta: Double = 0
    var thetaNorm: Double = 0
    
    var total: Double = 0
    
    
    init(appliedWindowSize: Int) {
        windowSize = appliedWindowSize
        timeInterval = Double(windowSize) / Double(Fs)
        var size: Int = Int(Double(NHz) * timeInterval)
        
        dataArray = [Double](count: size, repeatedValue: 0.0)
        
        fftSetup = vDSP_create_fftsetupD(UInt(log2(Double(windowSize))), FFTRadix(FFT_RADIX2))
    }
    
    func CalcPowerSpectrum (parsedData: [UInt32]) {
        let length = parsedData.count
        let startIndex = length - windowSize

        var realArray = UnsafeMutablePointer<Double>.alloc(windowSize)
        var imagArray = UnsafeMutablePointer<Double>.alloc(windowSize)
        for var i = 0; i < windowSize; ++i {
            realArray[i] = Double(parsedData[startIndex + i])
            imagArray[i] = 0.0
        }
        
        var complexData = DSPDoubleSplitComplex(realp: realArray, imagp: imagArray)
        complexData = Hamming(complexData)
        
        vDSP_fft_zipD(fftSetup, &complexData, 1, UInt(log2(Double(windowSize))),  FFTDirection(kFFTDirection_Forward))
        for var i = 0; i < Int(Double(NHz) * timeInterval); ++i {
            dataArray[i] = (sqrt( pow(complexData.realp[i], 2.0) + pow(complexData.imagp[i], 2.0))) / Double(windowSize)
        }
        
        total = dataArray.reduce(0, combine: +)
        delta = CalcBandPower(DeltaLower, upperLim: DeltaUpper);
        theta = CalcBandPower(ThetaLower, upperLim: ThetaUpper);
        alphaL = CalcBandPower(AlphaLLower, upperLim: AlphaLUpper);
        alphaH = CalcBandPower(AlphaHLower, upperLim: AlphaHUpper);
        betaL = CalcBandPower(BetaLLower, upperLim: BetaLUpper);
        betaH = CalcBandPower(BetaHLower, upperLim: BetaHUpper);
        gammaL = CalcBandPower(GammaLLower, upperLim: GammaLUpper);
        gammaH = CalcBandPower(GammaHLower, upperLim: GammaHUpper);

        deltaNorm = delta/total;
        thetaNorm = theta/total;
        alphaLNorm = alphaL/total;
        alphaHNorm = alphaH/total;
        betaLNorm = betaL/total;
        betaHNorm = betaH/total;
        gammaLNorm = gammaL/total;
        gammaHNorm = gammaH/total;
        
        realArray.dealloc(windowSize)
        imagArray.dealloc(windowSize)
    }
    
    func CalcBandPower(lowerLim: Int, upperLim: Int) -> Double {
        var power: Double = 0
        let startIndex: Int = Int(floor(Double(lowerLim) * timeInterval))
        let endIndex: Int = Int(floor(Double(upperLim) * timeInterval))

        for var i = startIndex; i < endIndex; ++i {
            power += dataArray[i]
        }
        power /= Double(endIndex - startIndex)
        return power
    }
    
    func Hamming(iwv: DSPDoubleSplitComplex) -> DSPDoubleSplitComplex{
        var length = windowSize
        for var i = 0; i < length; ++i {
            iwv.realp[i] = iwv.realp[i] * (0.54 - 0.46 * cos((2 * M_PI * Double(i)) / (Double(length) - 1.0) ))
        }
        return iwv
    }
}





