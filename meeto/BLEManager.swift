import Foundation
import CoreBluetooth
import SwiftUI

enum Command: UInt8 {
    case start = 0x01
    case pause = 0x03
    case resume = 0x04
    case reset = 0x05
    case data = 0x06
    case ask = 0x08
    case ack = 0x09
}

final class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    public static var shared: BluetoothManager = {
        let instance = BluetoothManager()
        return instance
    }()
    
    private var centeralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    public static let serviceUUID = CBUUID(string: "FFE0")
    public static let charUUID = CBUUID(string: "FFE1")
    public var characteristic: CBCharacteristic?
    private var stopScanTimer: Timer?
    
    @Published public var isReady = false
    @Published public var deviceConnected = false
    
    override init() {
        super.init()
        self.centeralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("invalid state $\(central.state) ")
            return
        }
        
        central.scanForPeripherals(withServices: [BluetoothManager.serviceUUID], options: nil)
        
        stopScanTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) {_ in
            central.stopScan()
            self.deviceConnected = false
        }
    }
    
    func scan() {
        if (!isReady && self.centeralManager != nil) {
            self.centeralManager.scanForPeripherals(withServices: [BluetoothManager.serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let target = advertisementData.filter { (key, elm) -> Bool in
            key == "kCBAdvDataManufacturerData"
        }
        
        // discover the BLE
        // how to get byte data? Data?
        let packet = target["kCBAdvDataManufacturerData"]
        
        if packet != nil {
            let d = (packet as! Data)
            // TODO: grab MAC address as well
            if (d[0] == 0x48 && d[1] == 0x4d && d[2] == 0xe4 && d[3] == 0xe1) {
                self.peripheral = peripheral
                self.centeralManager.connect(peripheral, options: nil)
                self.centeralManager.stopScan()
                stopScanTimer?.invalidate()
                stopScanTimer = nil
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([BluetoothManager.serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        self.isReady = false
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            print("discoverred!")
            for service in services {
                guard service.uuid == BluetoothManager.serviceUUID else {
                    print("can not get correct service UUID")
                    return
                }
                
                if (!self.deviceConnected) {
                    peripheral.discoverCharacteristics([BluetoothManager.charUUID], for: service)
                    self.deviceConnected = true
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("characteristic discoverred!")
        
        service.characteristics?.forEach { char in
            guard char.uuid == BluetoothManager.charUUID else { return }
            
            peripheral.setNotifyValue(true, for: char)
            self.isReady = true
            self.characteristic = char
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print(error)
            return
        }
        
        let data = characteristic.value!
        // TODO: handle data
    }
    
    func write(str: String) {
        if let peripheral = peripheral {
            guard peripheral.state == .connected else {
                print("You can't write value while peripheral is not in connected state")
                return
            }
            
            let byteArray = [UInt8]("\(str)\n".utf8)
            
            peripheral.writeValue(Data(byteArray), for: characteristic!, type: .withoutResponse)
        }
    }
}
