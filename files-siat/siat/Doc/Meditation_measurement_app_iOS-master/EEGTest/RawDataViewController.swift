//
//  RawDataViewController.swift
//  EEGTest
//
//  Created by Simiao Yu on 07/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol DataDelegate {
    func detectServices(CBService)
    func detectChar(CBCharacteristic)
    func updateGraph(eegData: EEGData)
}

class RawDataViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, DataDelegate {
    
    var lineChartView = JBLineChartView()
    
    var QualityView: UILabel?
    var BlinkView : UILabel?
    var ChewView : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // add background image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "NewRawBG")?.drawInRect(self.view.bounds)
        let BGImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: BGImage)
        
        central?.delegateData = self
        central?.connectedPeripheral?.discoverServices([CBUUID(string: TARGET_SERVICE_UUID)])
        
        let ViewHeight = CGFloat(50)
        
        // Raw data graph generation
        lineChartView.dataSource = self
        lineChartView.delegate = self
        lineChartView.backgroundColor = UIColor.clearColor()

        lineChartView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - CGFloat(49) - ViewHeight);
        lineChartView.minimumValue = CGFloat(0)
        lineChartView.maximumValue = CGFloat(4200)
        self.view.addSubview(lineChartView);
        
        // Info view generation
        QualityView = UILabel(frame:CGRectMake(0, self.view.frame.size.height - CGFloat(49) - ViewHeight, self.view.frame.size.width * 0.33, ViewHeight))
        BlinkView = UILabel(frame:CGRectMake(self.view.frame.size.width * 0.33, self.view.frame.size.height - CGFloat(49) - ViewHeight, self.view.frame.size.width * 0.67, ViewHeight))
        ChewView = UILabel(frame:CGRectMake(self.view.frame.size.width * 0.67, self.view.frame.size.height - CGFloat(49) - ViewHeight, self.view.frame.size.width, ViewHeight))
        
        self.view.addSubview(QualityView!)
        self.view.addSubview(BlinkView!)
        self.view.addSubview(ChewView!)
        
        println("Launched");
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Delegate method
    func detectServices(service: CBService) {
        central?.connectedPeripheral?.discoverCharacteristics(nil, forService: service)
    }
    
    // Delegate method
    func detectChar(char: CBCharacteristic) {
        central?.connectedPeripheral?.setNotifyValue(true, forCharacteristic: char)
    }

    // Raw graph properties
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }

    func lineChartView(lineChartView: JBLineChartView, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        
        return UInt(central!.parsedDataDisplay.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(central!.parsedDataDisplay[Int(horizontalIndex)])
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(3)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(red:0.28, green:0.23,blue:0.54,alpha:1)
    }

    // Delegate method
    func updateGraph(eegData: EEGData) {
        lineChartView.reloadData();
        if eegData.Quality == false {
            QualityView!.text = "脑波采集: 不良"
            QualityView!.textColor = UIColor.redColor()
        }
        else {
            QualityView!.text = "脑波采集: 良好"
            QualityView!.textColor = UIColor.blackColor()
        }
        
        if eegData.Blink == true {
            BlinkView!.text = "眨眼: 有"
            BlinkView!.textColor = UIColor.redColor()
        }
        else {
            BlinkView!.text = "眨眼: 无"
            BlinkView!.textColor = UIColor.blackColor()
        }
        
        if eegData.Tooth == true {
            ChewView!.text = "咬牙: 有"
            ChewView!.textColor = UIColor.redColor()
        }
        else{
            ChewView!.text = "咬牙: 无"
            ChewView!.textColor = UIColor.blackColor()
        }
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
