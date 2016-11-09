//
//  MeditationViewController.swift
//  EEGTest
//
//  Created by Simiao Yu on 16/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit
import AVFoundation

let MEDITATION_THRESHOLD: Float = 0.6

enum ButtonState {
    case Start, Stop, Reset
}

class MeditationViewController: UIViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, AVAudioPlayerDelegate
    {

    var player : AVAudioPlayer! = nil
    var playerClock : AVAudioPlayer! = nil
    
    var checkButtonState: ButtonState = .Start
    var canceled: Bool = false
    
    var accumulatedMed: Int = 0
    var targetMedTime: Int = 60
    var totalTimeSeconds: Int = 0
    
    var selectedMin: Int = 0
    var selectedSec: Int = 0
    
    @IBAction func cancelToMeditationViewController(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func saveMedSettings(segue:UIStoryboardSegue) {
        let sourceViewController = segue.sourceViewController as! MedSettingsViewController
        selectedMin = sourceViewController.selectedMin.toInt()!
        selectedSec = sourceViewController.selectedSec.toInt()!
        targetMedTime = selectedMin * 60 + selectedSec
        
        self.currentTimeSettings.text = secondToMinSecStr(targetMedTime)
    }
    
    // display current settings
    @IBOutlet weak var currentMusicSettings: UILabel!
    
    @IBOutlet weak var currentTimeSettings: UILabel!
    
    // prompt button for time setting
    @IBOutlet weak var timePrompt: UIButton!
    @IBAction func TimePrompt(sender: AnyObject) {
        let alertController = UIAlertController(title: "关于时间设置", message: "您好亲! 在点击\"开始冥想\"之前，请在页面右上角设置时间和音乐。\"时间设置\"代表冥想训练需要有效的冥想时间，无效的冥想不计入冥想时间的噢！训练时间完成后，会有钟声提醒噢！每天坚持训练，一个月后就能感觉大脑不一样了~~", preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
        }
        
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // display when doing meditation
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var totalTimeSpec: UILabel!
    @IBOutlet weak var remainingTime: UILabel!
    @IBOutlet weak var remainingTimeSpec: UILabel!
    @IBOutlet weak var progressRatio: UILabel!
    @IBOutlet weak var progressRatioSpec: UIProgressView!
    
    var ifPlayMusic = true
    @IBAction func musicButton(sender: AnyObject) {
        // prompt for music
        let alertController = UIAlertController(title: "冥想同时播放音乐?", message: "Canon in D Major", preferredStyle: .Alert)
        
        let YESAction = UIAlertAction(title: "播放", style: .Default) { (action) in
            self.ifPlayMusic = true
            self.currentMusicSettings.text = "播放音乐"
            }
        alertController.addAction(YESAction)
        
        let NOAction = UIAlertAction(title: "不播放", style: .Default) { (action) in
            self.ifPlayMusic = false
            self.currentMusicSettings.text = "不播放音乐"
        }
        alertController.addAction(NOAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    

    
    @IBOutlet weak var musicButtonOutlet: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func StartButton(sender: AnyObject) {
        if checkButtonState == .Start {
            checkButtonState = .Stop
            startButton.setTitle("停止冥想", forState: UIControlState.Normal)
            canceled = true
            
            // disable buttons
            timeButton.enabled = false
            timeButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            musicButtonOutlet.enabled = false
            musicButtonOutlet.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            
            // present info when meditation
            totalTimeSpec.text = secondToMinSecStr(0)
            totalTime.hidden = false
            totalTimeSpec.hidden = false
            
            remainingTimeSpec.text = secondToMinSecStr(targetMedTime)
            remainingTime.hidden = false
            remainingTimeSpec.hidden = false
            
            progressRatioSpec.setProgress(0, animated: false)
            progressRatio.hidden = false
            progressRatioSpec.hidden = false
            
            if self.ifPlayMusic == true {
                self.player.play()
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                while(self.canceled) {
                    if let score = central?.eegData.MeditationScore {
                        self.meditationHistory.append(score)
                        if score >= MEDITATION_THRESHOLD {
                            ++self.accumulatedMed
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // update total time
                            if self.totalTimeSeconds > 5999 {
                                self.totalTimeSeconds = 0
                            }
                            self.totalTimeSpec.text = self.secondToMinSecStr(self.totalTimeSeconds)
                            
                            // update remaining time
                            self.remainingTimeSpec.text = self.secondToMinSecStr(self.targetMedTime - self.accumulatedMed)
                            
                            // update progress bar
                            let progress:Float = Float(self.accumulatedMed) / Float(self.targetMedTime)
                            self.progressRatioSpec.setProgress(progress, animated: true)
                            
                            self.lineChartView.reloadData();
                            if self.accumulatedMed >= self.targetMedTime {
                                self.checkButtonState = .Reset
                                self.startButton.setTitle("重置", forState: UIControlState.Normal)
                                self.canceled = false

                                // stop playing music
                                if self.ifPlayMusic == true {
                                    self.player.stop()
                                    self.player.currentTime = 0
                                }
                                
                                // prompt for stoping medication
                                self.playerClock.play()
                                let alertController = UIAlertController(title: "冥想已完成", message: "已完成累计有效冥想时间: \(self.accumulatedMed) 秒", preferredStyle: .Alert)
                                    
                                let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
                                }
                                    
                                alertController.addAction(OKAction)
                                    
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                            return
                            })
                    }
                    sleep(1)
                    ++self.totalTimeSeconds
                }
            })
        }
        else if checkButtonState == .Stop {
            checkButtonState = .Reset
            startButton.setTitle("重置", forState: UIControlState.Normal)
            self.canceled = false
            if ifPlayMusic == true {
                // stop playing music
                self.player.stop()
                self.player.currentTime = 0
            }
            
            // prompt for stoping medication
            let alertController = UIAlertController(title: "冥想终止", message: "已完成累计有效冥想时间: \(self.secondToMinSecStr(self.accumulatedMed)) ", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
    
        }
            
        else {
            checkButtonState = .Start
            startButton.setTitle("开始冥想", forState: UIControlState.Normal)
            self.meditationHistory.removeAll(keepCapacity: false)
            self.lineChartView.reloadData();
            
            self.accumulatedMed = 0
            self.totalTimeSeconds = 0
            
            // enable buttons
            self.timeButton.enabled = true
            self.timeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            self.musicButtonOutlet.enabled = true
            self.musicButtonOutlet.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            
            // hidden info of meditation
            totalTime.hidden = true
            totalTimeSpec.hidden = true
            remainingTime.hidden = true
            remainingTimeSpec.hidden = true
            progressRatio.hidden = true
            progressRatioSpec.hidden = true
        }
    }
    
    var meditationHistory = [Float]()
    var lineChartView = JBLineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "medBG")?.drawInRect(self.view.bounds)
        let BGImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: BGImage)

        
        // Do any additional setup after loading the view.
        lineChartView.dataSource = self
        lineChartView.delegate = self
        lineChartView.backgroundColor = UIColor.clearColor()
        
        lineChartView.frame = CGRectMake(self.view.frame.width * 0.2, self.view.frame.height * 0.5, self.view.frame.width * 0.6, self.view.frame.height * 0.25);
        lineChartView.minimumValue = CGFloat(0)
        lineChartView.maximumValue = CGFloat(1)
        self.view.addSubview(lineChartView);
        
        // background music settings
        let path = NSBundle.mainBundle().pathForResource("Canon_in_D_Major", ofType:"mp3")
        let fileURL = NSURL(fileURLWithPath: path!)
        self.player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        self.player.prepareToPlay()
        self.player.delegate = self
        self.player.numberOfLoops = -1
        
        // remind clock music settings
        let pathClock = NSBundle.mainBundle().pathForResource("Clock", ofType:"mp3")
        let fileURLClock = NSURL(fileURLWithPath: pathClock!)
        self.playerClock = AVAudioPlayer(contentsOfURL: fileURLClock, error: nil)
        self.playerClock.prepareToPlay()
        self.playerClock.delegate = self
        self.playerClock.numberOfLoops = 2
        
        // current settings
        self.currentTimeSettings.text = "01分00秒"
        self.currentMusicSettings.text = "播放音乐"
        
        // hidden info when meditation
        totalTime.hidden = true
        totalTimeSpec.hidden = true
        remainingTime.hidden = true
        remainingTimeSpec.hidden = true
        progressRatio.hidden = true
        progressRatioSpec.hidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Meditation graph properties
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        
        return UInt(meditationHistory.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        var result = CGFloat(meditationHistory[Int(horizontalIndex)])
        if result < 0 {
            return 0
        }
        return result
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(1)
    }

    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        
        return UIColor(red:0.0, green:0.81,blue:1,alpha:0.5)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(red:0.48, green:0.82,blue:1,alpha:0.8)
    }
    
    
    func secondToMinSecStr(seconds: Int) -> String {
        let min: Int = seconds / 60
        let sec: Int = seconds - min * 60
        var minStr = "\(min)分"
        if min < 10 {
            minStr = "0" + minStr
        }
        var secStr = "\(sec)秒"
        if sec < 10 {
            secStr = "0" + secStr
        }
        return minStr + secStr
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
