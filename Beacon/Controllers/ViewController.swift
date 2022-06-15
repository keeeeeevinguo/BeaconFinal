import UIKit

class ViewController: UIViewController {
    
    let beaconManager = BeaconManager()  // manages beacon activity
    let pulseGraphic  = PulseGraphic()  // pulsating graphic
    let alertManager  = AlertManager()   // alerts


    @IBOutlet var labelBeacon        : UILabel!  // Title
    @IBOutlet var beaconSignalButton : UIButton! // start/transmit button
    @IBOutlet var uuid               : UILabel!
    @IBOutlet var segmentMajor       : UISegmentedControl!
    @IBOutlet var segmentMinor       : UISegmentedControl!
    @IBOutlet var labelBeaconID      : UILabel!
    
    //Start app
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBeaconDetails()
        setupPulse(view: beaconSignalButton)
        beaconManager.delegate = self
    }
    
    // Set up beacon
    func setupBeaconDetails() {
        beaconManager.createBeaconRegion()
        uuid.text          = K.uuid
        labelBeaconID.text = K.beaconID
    }
    
    //Set up pulse based on previous settings
    func setupPulse(view: UIView) {
        pulseGraphic.position = CGPoint(x: view.frame.size.width / 2 , y: view.frame.size.height / 2)
        view.layer.addSublayer(pulseGraphic)
    }
    

    // Switch segment control
    @IBAction func pickedSelectors(_ sender: UISegmentedControl) {
        beaconManager.createBeaconRegion(majorIndex: segmentMajor.selectedSegmentIndex,
                                         minorIndex: segmentMinor.selectedSegmentIndex)
        beaconManager.startAdvertising()
    }
    
    //Turn beacon on and off
    @IBAction func touchBeacon(_ sender: Any) {
        guard beaconManager.isBluetoothAvailable == true else {
            labelBeacon.text = K.labelNoBluetooth
            return
        }
        
        labelBeacon.text == K.transmitting ? beaconManager.stopAdvertising() : beaconManager.startAdvertising()
    }
}


extension ViewController: BeaconManagerDelegate {
    
    func showAlert(message: String) {
        alertManager.showAlert(self, message: message)
    }
    
    func advertiseDevice() {
        if pulseGraphic.pulse.isAnimating() == false { pulseGraphic.start() }
    }
    
    func stopAdvertising() {
        labelBeacon.text = K.start
        if pulseGraphic.pulse.isAnimating() == true { pulseGraphic.stop() }
    }
    
    func startAdvertising() {
        labelBeacon.text = K.transmitting
    }

}
