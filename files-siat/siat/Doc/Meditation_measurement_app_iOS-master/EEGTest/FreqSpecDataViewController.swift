//
//  FreqSpecDataViewController.swift
//  EEGTest
//
//  Created by Simiao Yu on 11/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol FreqDataDelegate {
    func updateGraph(eegData: EEGData)
}


class FreqSpecDataViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, FreqDataDelegate {
    
    var barChartView = JBBarChartView()
    var freqCompBarGraph = [Double]()
    
    var legendImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // add background image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "NewFreqBG")?.drawInRect(self.view.bounds)
        let BGImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: BGImage)
        
        central?.delegateFreqData = self
        
        // FreqSpec data graph generation
        barChartView.dataSource = self
        barChartView.delegate = self
        barChartView.backgroundColor = UIColor.clearColor()

        barChartView.frame = CGRectMake(30, 20, self.view.frame.size.width * 0.5, self.view.frame.size.height - 49 - 25);
        
        barChartView.minimumValue = CGFloat(0)
        barChartView.maximumValue = CGFloat(200)
        self.view.addSubview(barChartView);

        // For legends
        var legend: UIImage = UIImage(named: "legend.png")!
        legendImage = UIImageView(image: legend)
        legendImage?.frame = CGRectMake(self.view.frame.size.width * 0.5 + 40, 20, 179, 224)
        self.view.addSubview(legendImage!)
        
        println("Launched bar chart");

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // FreqSpec graph properties
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return 8
    }
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return  CGFloat(freqCompBarGraph[Int(index)]);
    }

    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        switch Int(index) {
        case 0:
            return UIColor.redColor()
        case 1:
            return UIColor.orangeColor()
        case 2:
            return UIColor.yellowColor()
        case 3:
            return UIColor.greenColor()
        case 4:
            return UIColor.blueColor()
        case 5:
            return UIColor.purpleColor()
        case 6:
            return UIColor.brownColor()
        case 7:
            return UIColor.magentaColor()
        default:
            return UIColor.blackColor()
        }

    }
    
    // Delegate method
    func updateGraph(eegData: EEGData) {
        freqCompBarGraph.removeAll(keepCapacity: true)
        
        freqCompBarGraph.append(eegData.DeltaPow)
        freqCompBarGraph.append(eegData.ThetaPow)
        freqCompBarGraph.append(eegData.AlphaPowLow)
        freqCompBarGraph.append(eegData.AlphaPowHi)
        freqCompBarGraph.append(eegData.BetaPowLow)
        freqCompBarGraph.append(eegData.BetaPowHi)
        freqCompBarGraph.append(eegData.GammaPowLow)
        freqCompBarGraph.append(eegData.GammaPowHi)
        barChartView.reloadData();
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

