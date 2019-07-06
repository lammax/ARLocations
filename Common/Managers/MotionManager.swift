//
//  YaMotionManager.swift
//  myPlace
//
//  Created by Mac on 08/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import CoreMotion
import UIKit

enum SensorData {
    /// Raw gyroscope data.
    case rawGyroData
    /// Raw accelerometer data.
    case rawAccelerometerData
    /// Raw magnetometer data.
    case rawMagnetometerData
    /// Rotation rate as returned by the `DeviceMotion` algorithms.
    case rotationRate
    /// User acceleration as returned by the `DeviceMotion` algorithms.
    case userAcceleration
    /// Gravity value as returned by the `DeviceMotion` algorithms.
    case gravity
    
    internal var description: String {
        switch self {
        case .rawGyroData:
            return "GyroData"
        case .rawAccelerometerData:
            return "AccelerometerData"
        case .rawMagnetometerData:
            return "MagnetometerData"
        case .rotationRate:
            return "RotationRateData"
        case .userAcceleration:
            return "UserAccelerationData"
        case .gravity:
            return "GravityData"
        }
    }
}

struct DataVector {
    var x : Double
    var y : Double
    var z : Double
}


protocol MotionManagerDelegate: class {
    func motionManager(didSensorUpdate sensor: [SensorData : DataVector])
}

class MotionManager {
    
    static let sharedInstance = MotionManager()
    weak var delegate: MotionManagerDelegate?
    
    private var latestSensorStringData: [String : String] = [:]
    private var latestSensorData: [SensorData : DataVector]? = [:] {
        didSet {
            if let sensorData = latestSensorData {
                self.delegate?.motionManager(didSensorUpdate: sensorData)
            }
        }
    }
    private var latestDeviceOrientation : CW = ._90

    /// CoreMotion manager instance we receive updates from.
    fileprivate let motionManager = CMMotionManager()
    
    internal enum CW {
        
        case _0
        case _90
        case _180
        case _270

        /// A description of the sensor as a `String`.
        internal var description: UIDeviceOrientation {
            switch self {
            case ._0:
                return .landscapeLeft
            case ._90:
                return .portrait
            case ._180:
                return .landscapeRight
            case ._270:
                return .portraitUpsideDown
            }
        }

    }
    
    internal enum DeviceSensor {
        
        /// Gyroscope
        case gyro
        /// Accelerometer
        case accelerometer
        /// Magnetormeter
        case magnetometer
        /// A set of iOS SDK algorithms that work with raw sensors data
        case deviceMotion
        
        /// A description of the sensor as a `String`.
        internal var description: String {
            switch self {
            case .gyro:
                return "Gyroscope"
            case .accelerometer:
                return "Accelerometer"
            case .magnetometer:
                return "Magnetometer"
            case .deviceMotion:
                return "Device Motion Algorithm"
            }
        }
        
    }
    
    init() {
        self.startUpdate()
    }
    
    deinit {
        self.stopUpdate()
    }
    
    func startUpdate() {
        // Initiate the `CoreMotion` updates to our callbacks.
        startAccelerometerUpdates()
        startGyroUpdates()
        startMagnetometerUpdates()
        startDeviceMotionUpdates()
    }
    
    func stopUpdate() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopMagnetometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Configuring CoreMotion callbacks triggered for each sensor
    
    /**
     *  Configure the raw accelerometer data callback.
     */
    fileprivate func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
                self.report(maybeAcceleration: accelerometerData?.acceleration, sensorData: .rawAccelerometerData)
                self.log(error: error, forSensor: .accelerometer)
            }
        }
    }
    
    /**
     *  Configure the raw gyroscope data callback.
     */
    fileprivate func startGyroUpdates() {
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: OperationQueue.main) { (gyroData, error) in
                self.report(maybeRotationRate: gyroData?.rotationRate, sensorData: .rawGyroData)
                self.log(error: error, forSensor: .gyro)
            }
        }
    }
    
    /**
     *  Configure the raw magnetometer data callback.
     */
    fileprivate func startMagnetometerUpdates() {
        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = 0.1
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (magnetometerData, error) in
                self.report(maybeMagneticField: magnetometerData?.magneticField, sensorData: .rawMagnetometerData)
                self.log(error: error, forSensor: .magnetometer)
            }
        }
    }
    
    /**
     *  Configure the Device Motion algorithm data callback.
     */
    fileprivate func startDeviceMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [unowned self] (deviceMotion, error) in
                self.report(maybeAcceleration: deviceMotion?.gravity, sensorData: .gravity)
                self.report(maybeAcceleration: deviceMotion?.userAcceleration, sensorData: .userAcceleration)
                self.report(maybeRotationRate: deviceMotion?.rotationRate, sensorData: .rotationRate)
                self.log(error: error, forSensor: .deviceMotion)
            }
        }
    }
    
    /**
     Logs an error in a consistent format.
     
     - parameter error:  Error value.
     - parameter sensor: `DeviceSensor` that triggered the error.
     */
    fileprivate func log(error: Error?, forSensor sensor: DeviceSensor) {
        guard let error = error else { return }
        
        NSLog("Error reading data from \(sensor.description): \n \(error) \n")
    }
    
    func getGravityStringData() -> String? {
        return latestSensorStringData[SensorData.gravity.description]
    }
    
    func deviceOrientation() -> UIDeviceOrientation {
        return self.latestDeviceOrientation.description
    }
    
}

extension MotionManager {
    /**
     - parameter rotationRate: A `CMRotationRate` holding the values to set.
     */
    internal func report(maybeRotationRate: CMRotationRate?, sensorData: SensorData) {
        let maybeDataVector: DataVector? = (maybeRotationRate == nil) ? nil : DataVector(x: maybeRotationRate!.x, y: maybeRotationRate!.y, z: maybeRotationRate!.z)
        process(maybeDataVector: maybeDataVector, sensorData: sensorData)
    }
    
    /**
     - parameter acceleration: A `CMAcceleration` holding the values to set.
     */
    internal func report(maybeAcceleration: CMAcceleration?, sensorData: SensorData) {
        let maybeDataVector: DataVector? = (maybeAcceleration == nil) ? nil : DataVector(x: maybeAcceleration!.x, y: maybeAcceleration!.y, z: maybeAcceleration!.z)
        process(maybeDataVector: maybeDataVector, sensorData: sensorData)
    }
    
    /**
     - parameter magnitude:     A `CMMagneticField` holding the values to set.
     */
    internal func report(maybeMagneticField: CMMagneticField?, sensorData: SensorData) {
        let maybeDataVector: DataVector? = (maybeMagneticField == nil) ? nil : DataVector(x: maybeMagneticField!.x, y: maybeMagneticField!.y, z: maybeMagneticField!.z)
        process(maybeDataVector: maybeDataVector, sensorData: sensorData)
    }
    
    fileprivate func saveDataString(maybeDataVector: DataVector?, sensorData: SensorData) {
        
        var dataString: String = "?"
        
        if let dataVector = maybeDataVector {
            
            /*
             var tempDataVector = dataVector
            //rotation start
            tempDataVector.y = -tempDataVector.y;
            tempDataVector.z = -tempDataVector.z;
            
            if (self.latestDeviceOrientation == CW._90) {
            }
            else if (self.latestDeviceOrientation == CW._270) {
                tempDataVector.x = -tempDataVector.x;
                tempDataVector.y = -tempDataVector.y;
            }
            else if (self.latestDeviceOrientation == CW._0) {
                swap(&tempDataVector.y, &tempDataVector.x)
                tempDataVector.y = -tempDataVector.y;
            }
            else if (self.latestDeviceOrientation == CW._180) {
                swap(&tempDataVector.y, &tempDataVector.x)
                tempDataVector.x = -tempDataVector.x;
            }
            //rotation end
            */

            let dataArray: [String] = [
                String(format: "%.2f", arguments: [dataVector.x]),
                String(format: "%.2f", arguments: [dataVector.y]),
                String(format: "%.2f", arguments: [dataVector.z])
            ]
            dataString = dataArray.joined(separator: " ")
            
            self.latestSensorData?[sensorData] = dataVector
        }
        self.latestSensorStringData[sensorData.description] = dataString
    }
    
    func dataToString(dataVector: DataVector, decimal: Int = 2, separator: String = " ") -> String {
        let dataArray: [String] = [
            String(format: "%.\(decimal)f", arguments: [dataVector.x]),
            String(format: "%.\(decimal)f", arguments: [dataVector.y]),
            String(format: "%.\(decimal)f", arguments: [dataVector.z])
        ]
        return dataArray.joined(separator: separator)
    }
    
    fileprivate func saveDeviceOrientation(maybeDataVector: DataVector?) {
        
        guard let dataVector = maybeDataVector else { self.latestDeviceOrientation = CW._90; return }
        
        if dataVector.x < -0.5 {
            self.latestDeviceOrientation = CW._0
        } else if dataVector.x > 0.5 {
            self.latestDeviceOrientation = CW._180
        } else if dataVector.y > 0.5 {
            self.latestDeviceOrientation = CW._270
        } else {
            self.latestDeviceOrientation = CW._90
        }
        
    }

    fileprivate func process(maybeDataVector: DataVector? = nil, sensorData: SensorData) {
        
        
        //Done for future possible changes in final values mutations, for example, different axis directions or positions of phone
        switch sensorData {
        case .gravity:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rawAccelerometerData:
            saveDeviceOrientation(maybeDataVector: maybeDataVector)
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rawGyroData:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rawMagnetometerData:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .rotationRate:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        case .userAcceleration:
            saveDataString(maybeDataVector: maybeDataVector, sensorData: sensorData)
        }
        
    }

}
