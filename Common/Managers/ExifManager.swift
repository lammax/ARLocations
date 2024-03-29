//
//  YaExifManager.swift
//  myPlace
//
//  Created by Mac on 09/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import CoreLocation
import ImageIO

enum NorthDirection {
    case True
    case Magnetic
}

class ExifManager {
    
    static let sharedInstance = ExifManager()
    
    private func _getGpsMetadata(with maybeLocation: CLLocation? = nil, maybeHeading: CLHeading? = nil) -> NSMutableDictionary {
        
        let GPSMetadata = NSMutableDictionary()
        
        if let location = maybeLocation {
            let f = DateFormatter()
            f.timeZone = TimeZone(abbreviation: "UTC")
            
            f.dateFormat = "yyyy:MM:dd"
            let isoDate = f.string(from: location.timestamp)
            
            f.dateFormat = "HH:mm:ss.SSSSSS"
            let isoTime = f.string(from: location.timestamp)
            
            let altitudeRef = Int(location.altitude < 0.0 ? 1 : 0)
            let latitudeRef = location.coordinate.latitude < 0.0 ? "S" : "N"
            let longitudeRef = location.coordinate.longitude < 0.0 ? "W" : "E"
            
            // GPS metadata
            GPSMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(location.coordinate.latitude)
            GPSMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(location.coordinate.longitude)
            GPSMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
            GPSMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
            
            GPSMetadata[(kCGImagePropertyGPSAltitude as String)] = Int(abs(location.altitude))
            GPSMetadata[(kCGImagePropertyGPSAltitudeRef as String)] = altitudeRef
            
            GPSMetadata[(kCGImagePropertyGPSTimeStamp as String)] = isoTime
            GPSMetadata[(kCGImagePropertyGPSDateStamp as String)] = isoDate
            
            //0x000b    GPSDOP    rational64u
            GPSMetadata[(kCGImagePropertyGPSDOP as String)] = location.horizontalAccuracy
            
        }
        
        if let heading = maybeHeading {
            //0x0011    GPSImgDirection    rational64u
            GPSMetadata[(kCGImagePropertyGPSImgDirection as String)] = heading.trueHeading;
            GPSMetadata[(kCGImagePropertyGPSImgDirectionRef as String)] = "T"
        }
        
        return GPSMetadata
    }
    
    private func _getTiffMetadata(with data: Data, exifKey: CFString, maybeValue: String?) -> NSMutableDictionary {
        
        var TIFFMetadata = NSMutableDictionary()
        
        //get metadata
        let source = CGImageSourceCreateWithData(data as NSData, nil)!
        let metadata = NSMutableDictionary(dictionary: CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!)
        
        //Load TIFF
        if let tiffDict = metadata[kCGImagePropertyTIFFDictionary as String] as? NSMutableDictionary {
            TIFFMetadata = tiffDict
        }
        
        //Gravity data
        if let value = maybeValue {
            TIFFMetadata[(exifKey as String)] = value
        }
        
        return TIFFMetadata
    }

    private func _addGpsMetadata(with data: Data, gpsData: NSMutableDictionary) -> Data {
        return self._addMetaToData(with: data, addMeta: gpsData, metaKey: kCGImagePropertyGPSDictionary)
    }

    private func _addTIFFMetadata(with data: Data, tiffData: NSMutableDictionary) -> Data {
        return self._addMetaToData(with: data, addMeta: tiffData, metaKey: kCGImagePropertyTIFFDictionary)
    }
    
    private func _getMetaData(from data: Data, metaKey: CFString) -> Any? {
        return (data.getMetaData())[metaKey as String]
    }
    
    private func _getLocation(from gpsDict: [String:Any]) -> CLLocation? {
        
        let latitude = gpsDict[kCGImagePropertyGPSLatitude as String] as? Double
        let latitudeRef = gpsDict[(kCGImagePropertyGPSLatitudeRef as String)] as? String

        let longitude = gpsDict[kCGImagePropertyGPSLongitude as String] as? Double
        let longitudeRef = gpsDict[(kCGImagePropertyGPSLongitudeRef as String)] as? String
        
        let altitude = gpsDict[(kCGImagePropertyGPSAltitude as String)] as? Double
        let altitudeRef = gpsDict[(kCGImagePropertyGPSAltitudeRef as String)] as? Int
        
        let time = gpsDict[(kCGImagePropertyGPSTimeStamp as String)] as? String
        let date = gpsDict[(kCGImagePropertyGPSDateStamp as String)] as? String
        
        let horizontalAccuracy = gpsDict[(kCGImagePropertyGPSDOP as String)] as? Double
        
        let direction = gpsDict[(kCGImagePropertyGPSImgDirection as String)] as? Double //True North
        
        if let lat = latitude, let lon = longitude,
            let latRef = latitudeRef, let lonRef = longitudeRef,
            let alt = altitude, let altRef = altitudeRef,
            let t = time, let d = date,
            let hAcc = horizontalAccuracy, let dir = direction {
            
            let latitudeSign: Double = {
                switch latRef.uppercased() {
                case "W":
                    return -1
                case "N":
                    return 1
                default:
                    return 0
                }
            }()
            let longitudeSign: Double = {
                switch lonRef.uppercased() {
                case "W":
                    return -1
                case "E":
                    return 1
                default:
                    return 0
                }
            }()
            let altitudeSign: Double = {
                switch altRef {
                case 1:
                    return -1
                case 0:
                    return 1
                default:
                    return 0
                }
            }()

            let coordinate = CLLocationCoordinate2D(latitude: lat * latitudeSign, longitude: lon * longitudeSign)
            let altitude = alt * altitudeSign
            let horizontalAccuracy = hAcc
            let dateFormatter = DateFormatter()
            let dateS = d + " " + t
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone.current //Bug with TimeZone, shows 08:00 instead 11:00
            dateFormatter.locale = Locale.current
            let date = dateFormatter.date(from:dateS)!
            
            return CLLocation(coordinate: coordinate, altitude:  altitude, horizontalAccuracy: horizontalAccuracy, verticalAccuracy: 0, course: dir, speed: 0, timestamp: date)

        } else {
            return nil
        }
        
    }
    
    private func _addMetaToData(with data: Data, addMeta: NSMutableDictionary, metaKey: CFString) -> Data {
        //get metadata
        let source = CGImageSourceCreateWithData(data as NSData, nil)!
        let metadata = NSMutableDictionary(dictionary: CGImageSourceCopyPropertiesAtIndex(source, 0, nil)!)
        
        //add metadata
        metadata.setValue(addMeta, forKey: metaKey as String)
        
        //save new metadata
        let UTI: CFString = CGImageSourceGetType(source)!
        let dest_data = NSMutableData()
        let destination: CGImageDestination = CGImageDestinationCreateWithData(dest_data as CFMutableData, UTI, 1, nil)!
        CGImageDestinationAddImageFromSource(destination, source, 0, metadata)
        CGImageDestinationFinalize(destination)
        
        return dest_data as Data
    }

    func appendGPSMetadata(with data: Data, maybeLocation: CLLocation? = nil, maybeHeading: CLHeading? = nil) -> Data {
        return self._addGpsMetadata(
            with: data,
            gpsData: self._getGpsMetadata(with: maybeLocation, maybeHeading: maybeHeading)
        )
    }

    func appendTIFFMetadata(with data: Data, maybeImgDesc: String?) -> Data {
        return self._addTIFFMetadata(
            with: data,
            tiffData: self._getTiffMetadata(with: data, exifKey: kCGImagePropertyTIFFImageDescription, maybeValue: maybeImgDesc)
        )
    }
    
    func appendDeviceMetadata(with maybeData: Data?, maybeLocation: CLLocation? = nil, maybeHeading: CLHeading? = nil, maybeImgDesc: String?) -> Data? {
        
        guard let data = maybeData else { return nil }
        
        var newData: Data = data
        
        newData = appendGPSMetadata(with: newData, maybeLocation: maybeLocation, maybeHeading: maybeHeading)
        newData = appendTIFFMetadata(with: newData, maybeImgDesc: maybeImgDesc)
        
        return newData
    }
    
    func getLocation(maybeData: Data?) -> CLLocation? {
        if let data = maybeData, let dict = self._getMetaData(from: data, metaKey: kCGImagePropertyGPSDictionary) as? Dictionary<String, Any> {
            return self._getLocation(from: dict)
        } else {
            return nil
        }
    }
    
    func getHeading(heading: CLHeading, north: NorthDirection) -> Double {
        switch north {
        case .True:
            return heading.trueHeading
        case .Magnetic:
            return heading.magneticHeading
        }
    }

    func getLocatonPoint(location: CLLocation) -> CGPoint {
        return CGPoint(x: location.coordinate.latitude, y: location.coordinate.longitude)
    }
    
    func getLocatonAccuracy(location: CLLocation) -> Double {
        return location.horizontalAccuracy
    }
    
}
