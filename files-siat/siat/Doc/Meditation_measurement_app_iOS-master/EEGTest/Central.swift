//
//  Central.swift
//  EEGTest
//
//  Created by Simiao Yu on 06/02/2015.
//  Copyright (c) 2015 test. All rights reserved.
//

import UIKit
import CoreBluetooth

let TARGET_SERVICE_UUID = "FFE0"
let PACKET_TITLE = "a55a05ffff"
let RAW_GRAPH_WIDTH = 100

let WIN_SIZE_FREQ_COMP = 512
let WIN_SIZE_BRAIN_FEATURE = 2048
let FREQ_COMP_TIME = 102
let BRAIN_FEATURE_TIME = 512

extension NSData {
    var hexString: String {
        var bytes = [UInt8](count: length, repeatedValue: 0)
        getBytes(&bytes, length: length)
        
        let convertedString = NSMutableString()
        
        for byte in bytes {
            convertedString.appendFormat("%02x", UInt(byte))
        }
        
        return NSString(string: convertedString) as String
    }
}

class Central: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager?
    
    var delegate: DetectNewDeviceDelegate?
    var delegateData: DataDelegate?
    var delegateFreqData: FreqDataDelegate?
    
    var detectedPeripheral = Dictionary<String, CBPeripheral>()//创建一个空字典
    var connectedPeripheral: CBPeripheral?
    
    var receivedData = String()
    
    var battery: UInt32 = 0
    
    var parsedDataDisplay = [UInt32]()
    var parsedData = [UInt32]()
    var mergePointIndex = 3
    var pointNum: Int = 0
    var validPointNum: Int = 0
    
//    // use for test packet error rate
//    var testID: UInt32 = 0
//    var last: UInt32 = 0
//    var droped = 0
    
    var eegData = EEGData()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        switch central.state {
        case CBCentralManagerState.Unknown:
            println("BLE Unknown")
        case CBCentralManagerState.Resetting:
            println("BLE Resetting")
        case CBCentralManagerState.Unsupported:
            println("BLE Unsupported")
        case CBCentralManagerState.Unauthorized:
            println("BLE Unauthorized")
        case CBCentralManagerState.PoweredOff:
            println("BLE PoweredOff")
        case CBCentralManagerState.PoweredOn:
            println("BLE PoweredOn")
            centralManager!.scanForPeripheralsWithServices(nil, options: nil)
        default:
            println("Unknown State")
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered \(peripheral.name) \(RSSI.stringValue)")
        if let detectedDevice = peripheral {
            if let name = detectedDevice.name {
                detectedPeripheral[detectedDevice.name] = peripheral 
                delegate?.addNewDevice(detectedDevice.name, RSSI: RSSI.integerValue)
            }
        }
    }
    
    func resetDetectedDevices() {
        detectedPeripheral.removeAll(keepCapacity: false)
    }
    
    func connecting(selectedDevice: String) {
        centralManager!.stopScan()
        connectedPeripheral = detectedPeripheral[selectedDevice]
        centralManager!.connectPeripheral(connectedPeripheral!, options: nil)
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("connected!")
        connectedPeripheral!.delegate = self
        delegate?.checkConnection(true, errorMessage: String() )
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("connection fail!")
        delegate?.checkConnection(false, errorMessage: error.localizedDescription )
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        for service in peripheral.services {
            println(service)
        }
        delegateData?.detectServices(peripheral.services[0] as! CBService)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        for char in service.characteristics {
            println(char)
        }
        
        delegateData?.detectChar(service.characteristics[0] as! CBCharacteristic)
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        parseNSData(characteristic.value.hexString)
    }
    
    func parseNSData(value: String) {
        
        if count(value) == 40 && value.substringWithRange(Range<String.Index>(start: advance(value.startIndex, 0), end: advance(value.startIndex, 10))) == PACKET_TITLE {
            receivedData = value
        }
        
        else {
            
            receivedData += value
            
            if count(receivedData) == 58 && receivedData.substringWithRange(Range<String.Index>(start: advance(receivedData.startIndex, 0), end: advance(receivedData.startIndex, 10))) == PACKET_TITLE {
                
                battery = getBattery(receivedData.substringWithRange(Range<String.Index>(start: advance(receivedData.startIndex, 10), end: advance(receivedData.startIndex, 12))))
                
                let data = receivedData.substringWithRange(Range<String.Index>(start: advance(receivedData.startIndex, 14), end: advance(receivedData.startIndex, 54)))
                
                for var i = 0; i < count(data); i += 4 {
                    
                    ++pointNum
                    
                    let sampleData = data.substringWithRange(Range<String.Index>(start: advance(data.startIndex, i), end: advance(data.startIndex, i + 4)))

                    let scanner = NSScanner(string: sampleData)
                    var result : UInt32 = 0
                    
                    if scanner.scanHexInt(&result) {
                        if pointNum % 3 == 0 {
                            parsedDataDisplay.append(result)
                        }
                        parsedData.append(result)
                    }
                    
                    let length = parsedData.count
                    if pointNum % FREQ_COMP_TIME == 0 {
                        if length >= WIN_SIZE_FREQ_COMP {
                            eegData.UpdateNonBrainFeature(parsedData)
                            if eegData.ValidData() {
                                ++validPointNum
                            }
                            else {
                                validPointNum = 0
                            }
                        }
                    }
                    
                    if pointNum % BRAIN_FEATURE_TIME == 0 {
                        pointNum = 0
                        if length >= WIN_SIZE_BRAIN_FEATURE && validPointNum >= 20 {
                            eegData.UpdateBrainFeature(parsedData)
                        }
                        else {
                            eegData.MeditationScore -= 0.25
                            if eegData.MeditationScore < 0 {
                                eegData.MeditationScore = 0
                            }
                        }
                    }
                    
                    if parsedDataDisplay.count >= RAW_GRAPH_WIDTH {
                        parsedDataDisplay.removeAtIndex(0)
                    }
                    
                    if parsedData.count >= WIN_SIZE_BRAIN_FEATURE {
                        parsedData.removeAtIndex(0)
                    }
                    
                }
                
                
                delegateData?.updateGraph(eegData)
                delegateFreqData?.updateGraph(eegData)
                
//                // test packet error rate
//                ++testID
//            
//                let ID = receivedData.substringWithRange(Range<String.Index>(start: advance(receivedData.startIndex, 12), end: advance(receivedData.startIndex, 14)))
//            
//                let scanner = NSScanner(string: ID)
//                var result : UInt32 = 0
//                
//                if scanner.scanHexInt(&result) {
//                    if testID == 1 {
//                        last = result
//                    }
//                    else if result == 0 {
//                        if last != 255 {
//                            ++droped
//                        }
//                    }
//                    else if result - last != 1 {
//                        ++droped
//                    }
//                    
//                }
//
//                println("packet ID: \(ID): (dropped)\(droped) / (tested)\(testID)......(current ID)\(result)..(last ID)\(last)")
//                last = result
            }
            

        }

    }
    
    func getBattery(data: String) -> UInt32 {
        let scanner = NSScanner(string: data)
        var result : UInt32 = 0
        
        if scanner.scanHexInt(&result) {
            return result
        }
        else {
            return 0
        }
    }
    
    func disconnect() {
        centralManager?.cancelPeripheralConnection(connectedPeripheral)
        connectedPeripheral = nil
    }
}
