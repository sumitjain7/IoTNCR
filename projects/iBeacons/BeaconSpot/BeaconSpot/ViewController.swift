//
//  ViewController.swift
//  BeaconSpot
//
//  Created by Sumit Jain.
//

import UIKit
import QuartzCore
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {

	private var appdel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
	
    @IBOutlet weak var btnSwitchSpotting: UIButton!
    
    @IBOutlet weak var lblBeaconReport: UILabel!
    
    @IBOutlet weak var lblBeaconDetails: UILabel!
	
	let beaconUUID:String = "F34A1A1F-500F-48FB-AFAA-9584D641D7B1";
    
    var beaconRegion: CLBeaconRegion!
    
    var locationManager: CLLocationManager!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.Unknown
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lblBeaconDetails.hidden = true
        btnSwitchSpotting.layer.cornerRadius = 30.0
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        let uuid = NSUUID(UUIDString: beaconUUID)!
//		  let uuid = NSUUID(UUIDString: "00000000-0000-0000-0000-000000000000")!;
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "com.iot.beacon")
        
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
		
		let loc:UILocalNotification = UILocalNotification();
		loc.alertBody = "We are having a deal for you!!!";
		loc.fireDate = NSDate(timeIntervalSinceNow: 20);
		UIApplication.sharedApplication().scheduleLocalNotification(loc);
		
		
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated);
		if(appdel.isInvokedFromLocalNotification)
		{
			appdel.isInvokedFromLocalNotification = false;
			let offerVC:OfferViewController = self.storyboard?.instantiateViewControllerWithIdentifier("offerVC") as! OfferViewController;
			offerVC.UUID = beaconUUID;
			dispatch_async(dispatch_get_main_queue()){
				self.presentViewController(offerVC, animated: true, completion: nil);
			}
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: IBAction method implementation
    
    @IBAction func switchSpotting(sender: AnyObject) {
        if !isSearchingForBeacons {
            locationManager.requestAlwaysAuthorization()
			locationManager.startMonitoringForRegion(beaconRegion);
			//locationManager
            locationManager.startUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Stop Spotting", forState: UIControlState.Normal)
            lblBeaconReport.text = "Spotting beacons..."
        }
        else {
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
            locationManager.stopUpdatingLocation()
            
            btnSwitchSpotting.setTitle("Start Spotting", forState: UIControlState.Normal)
            lblBeaconReport.text = "Not running"
            lblBeaconDetails.hidden = true
        }
        
        isSearchingForBeacons = !isSearchingForBeacons
    }
    
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.requestStateForRegion(region)
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state == CLRegionState.Inside {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }

    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        lblBeaconReport.text = "Beacon in range"
        lblBeaconDetails.hidden = false
		let loc:UILocalNotification = UILocalNotification();
		loc.alertBody = "you have entered region";
		UIApplication.sharedApplication().presentLocalNotificationNow(loc);
    }
	
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        lblBeaconReport.text = "No beacons in range"
        lblBeaconDetails.hidden = false
		let loc:UILocalNotification = UILocalNotification();
		loc.alertBody = "you have exited from region";
		UIApplication.sharedApplication().presentLocalNotificationNow(loc);
    }
	
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        var shouldHideBeaconDetails = true
       // region.per
		if let foundBeacons:[CLBeacon] = beacons{
            if foundBeacons.count > 0 {
                if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.Immediate:
                            proximityMessage = "Very close"
							
                            
                        case CLProximity.Near:
                            proximityMessage = "Near"
                            
                        case CLProximity.Far:
                            proximityMessage = "Far"
                            
                        default:
                            proximityMessage = "Where's the beacon?"
                        }
                        
                        shouldHideBeaconDetails = false
                        
                        lblBeaconDetails.text = "Beacon Details:\nMajor = " + String(closestBeacon.major.intValue) + "\nMinor = " + String(closestBeacon.minor.intValue) + "\nDistance: " + proximityMessage
                    }
                }
            }
        }
        
        lblBeaconDetails.hidden = shouldHideBeaconDetails
    }
 
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print(error)
    }
}

