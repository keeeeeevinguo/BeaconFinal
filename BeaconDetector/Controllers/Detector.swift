import Foundation
import CoreLocation
import SwiftUI

class Detector: NSObject, ObservableObject {
    
    var locationManager = CLLocationManager()
    var showAlert = false
    //Variables being used
    @Published var lastDistance     = K.emptyString
    @Published var major : NSNumber = 0
    @Published var minor : NSNumber = 0
    @Published var RSSID = 0
    @Published var accuracy            = 0.0
    @Published var beaconID         = K.emptyString
    @Published var bgColor          = Color("Unknown")
    @Published var alert            = K.emptyString
    
    override init () {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        verifyPrivacyAuthorization()
    }
    //Ensure location services are available
    func verifyPrivacyAuthorization() {
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            startScanning()
        } else {
            showAlert = true
            alert = K.locationNeeded
            print("alert to change location settings")
        }
    }
    //Looking for missing device
    func startScanning() {
        
        guard let uuid = UUID(uuidString: K.uuid) else { return }
        
        let constraint = CLBeaconIdentityConstraint(uuid: uuid)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: K.beaconID)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: constraint)
    }

    //Proximity display
    func update(distance: CLProximity) -> (color: Color, distance: String) {
        switch distance {
            case .immediate : return (Color("Immediate"), BeaconStatus.immediate.rawValue)
            case .near      : return (Color("Near"), BeaconStatus.near.rawValue)
            case .far       : return (Color("Far"), BeaconStatus.far.rawValue)
            default         : return (Color("Unknown"), BeaconStatus.unknown.rawValue)
        }
    }
    
}

//check conditions for use are satisfied and start looking for missing device
extension Detector: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
//Gather information from missing device
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {

        if let beacon = beacons.first {
            lastDistance = update(distance: beacon.proximity).distance
            bgColor      = update(distance: beacon.proximity).color
            major        = beacon.major
            minor        = beacon.minor
            beaconID     = beacon.description
            RSSID = beacon.rssi
            accuracy=beacon.accuracy

            
            let key: String = String(describing: major) + "-" + String(describing: minor)
            
            
        } else {
            lastDistance = BeaconStatus.unknown.rawValue
        }
    }
}




