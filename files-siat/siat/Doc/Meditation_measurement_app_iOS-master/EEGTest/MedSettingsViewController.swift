//
//  MedSettingsViewController.swift
//  EEGTest
//
//  Created by Simiao Yu on 08/03/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit

class MedSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
    {
    var timePicker: UIPickerView!
    
    var timeSeconds = [String]()
    var timeMinutes = [String]()
    
    var selectedMin = ""
    var selectedSec = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // set second array
        for i in 0..<60 {
            timeSeconds.append(String(i))
        }
        // set minute array
        for i in 0...90 {
            timeMinutes.append(String(i))
        }
        
        timePicker = UIPickerView()
        timePicker.dataSource = self
        timePicker.delegate = self
        timePicker.center = view.center
        
        timePicker.selectRow(1, inComponent: 0, animated: false)
        timePicker.selectRow(0, inComponent: 1, animated: false)
        
        view.addSubview(timePicker)
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        selectedMin = timeMinutes[timePicker.selectedRowInComponent(0)]
        selectedSec = timeSeconds[timePicker.selectedRowInComponent(1)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return timeMinutes.count
        }
        else {
            return timeSeconds.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if component == 0 {
            return timeMinutes[row] + " 分"
        }
        else {
            return timeSeconds[row] + " 秒"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if timePicker.selectedRowInComponent(0) == 0 && timePicker.selectedRowInComponent(1) == 0 {
            timePicker.selectRow(1, inComponent: 1, animated: true)
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
