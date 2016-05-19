//
//  ViewController.swift

//  mapka22.12
//
//  Created by Adam Sekeres on 22.12.2015.
//  Copyright © 2015 Adam Sekeres. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AudioToolbox
import AVFoundation
import AudioToolbox
import WatchConnectivity


protocol RecordsDelegate {
    func getDataFromBluemix(data records:[Kamera])
}

//MARK: NAJNOVSI FILE

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, AVAudioPlayerDelegate, UIApplicationDelegate,WCSessionDelegate,CDTReplicatorDelegate
{
    var locationManager = CLLocationManager()
    var map : MKMapView!
    var annotation : MKPointAnnotation?
    var audioPlayer:AVAudioPlayer!
    var records = [Kamera]()
    var userIsNearTheCamera = false
    var dataFromURL = [[String:AnyObject]]()
    var userLocation : CLLocation?
    var enableSounds : Bool!
    var DistanceForNotifyUser : Double!
    let group = dispatch_group_create();
    var delegate : RecordsDelegate?
    var session : WCSession!
    var myDataStore : AnyObject?
    var myReplicator : CDTReplicator!



    override func loadView() {
        super.loadView()
        let m = MKMapView(frame: self.view.frame)
        self.view.addSubview(m)
        m.showsUserLocation = true
        m.mapType = MKMapType.Standard
        m.delegate = self
        self.map = m
        
        
        let defaults = NSUserDefaults(suiteName: "SettingsDefaults")
        
        if let Sounds = defaults?.objectForKey("SwitchValue") as? Bool {
            self.enableSounds = Sounds
        }   else {
            self.enableSounds = true
        }
        
        if let Distance = defaults?.objectForKey("StepperValue") as? Double {
            self.DistanceForNotifyUser = Distance
        }   else {
            self.DistanceForNotifyUser = 100.0
        }
      
        do {
     
            let fileManager = NSFileManager.defaultManager()
            //Vezme aktualnu cestu uloziska zariadenia
            let documentsDir = fileManager.URLsForDirectory(.DocumentDirectory,
                inDomains: .UserDomainMask).last!
            let storeURL = documentsDir.URLByAppendingPathComponent("cloudant-sync-datastore")
            let path = storeURL.path
             //vytvori filemanager 
            let manager = try CDTDatastoreManager(directory: path)
            let datastore = try manager.datastoreNamed("my_datastore")
            self.myDataStore = datastore
            let replicatorFactory = CDTReplicatorFactory(datastoreManager: manager)
            let s = "https://898317c1-8fab-488c-a0b5-7b989a6788eb-bluemix:dbd6864d382e459748aa5d638e779e7ee719851f8a86f980f77d3fef06a93b9f@898317c1-8fab-488c-a0b5-7b989a6788eb-bluemix.cloudant.com/cameradb"
            let remoteDatabaseURL = NSURL(string: s)
            
            let pullReplication = CDTPullReplication(source:remoteDatabaseURL, target:datastore)
            let replicator =  try replicatorFactory.oneWay(pullReplication)
            self.myReplicator = replicator
            self.myReplicator.delegate = self
            
          // Start the replicator
           
            try self.myReplicator.start()
            
         } catch {
            print("Encountered an error: \(error)")
        }
        
      
        dispatch_group_notify(self.group, dispatch_get_main_queue()) { () -> Void in
            if(self.delegate != nil){
                self.delegate!.getDataFromBluemix(data: self.records)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // print(annotation.title)
        
        if(annotation is MKUserLocation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("myPin")
        
        if (annotationView == nil) {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        }
        
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    
    // Add camera annotations to map view
    func addAnnotationsToMapView() -> Bool {
       
       if self.records.count > 0 {
               let records = self.records
        
                for record in records {
                    let pin = MKPointAnnotation()
                    var location = CLLocationCoordinate2D() /* if let treba */
                    location.latitude = (record.latitude?.doubleValue)!
                    location.longitude = (record.longitude?.doubleValue)!
                    pin.coordinate = location
                    pin.title = record.meno
                    
                    if((self.map) != nil){
                        mapView(self.map, viewForAnnotation: pin)
                        self.map.addAnnotation(pin)
                    }
                }
        } else {
                 return false
        }
        return true
    }
    
    
    
    
    
    func replicatorDidComplete(replicator: CDTReplicator!) {
        
        if let data = self.myDataStore {
            let documentRevisions = data.getAllDocuments()
            
            for document in documentRevisions {
                if let body = document.body {
                    if let cameras = body["records"] as? [[String:AnyObject]] {
                        for record in cameras {
                            if let cameraLon = record["long"] as? NSString {
                                if let cameraLat = record["lat"] as? NSString {
                                    if let cameraName = record["name"] as? String {
                                        if let cameraID = record["_id"] as? NSNumber {
                                            
                                            let camera =  Kamera(name: cameraName, id: cameraID, longitude: cameraLon.doubleValue, latitude: cameraLat.doubleValue)
                                            self.records.append(camera)
                                        }}}}}}}}}
        dispatch_group_notify(self.group, dispatch_get_main_queue()) { () -> Void in
            if(self.delegate != nil){
                self.delegate!.getDataFromBluemix(data: self.records)
            }
            self.addAnnotationsToMapView()
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        self.userLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    func sendDataToAppleWatch(dataToSend data: [Kamera]) -> Bool {
        var dataToWatch = [NSDictionary]()
        
        if(data.count == 0) { return false }
        if(WCSession.isSupported()){
            print("WCsession supported on Iphone")
            
            if let userLocation = self.userLocation {
                for index in 0..<data.count {
                    if let longitude = records[index].longitude  {
                        if let latitude = records[index].latitude{
                            // Creating camera CLLocation
                            let cameraLocation = CLLocation(latitude: latitude.doubleValue,     longitude: longitude.doubleValue)
                            let distance =  userLocation.distanceFromLocation(cameraLocation)
                            let dictionary = NSDictionary(dictionary: ["meno":records[index].meno, "distance" : distance])
                            dataToWatch.append(dictionary)
                        }
                    }
                }
                
                self.session = WCSession.defaultSession()
                self.session.delegate = self
                self.session.activateSession()
                self.session.sendMessage(["cameraRecords": dataToWatch ], replyHandler: nil, errorHandler: { (error) -> Void in
                    print(error)
                })
                
            }   else {
                        return false
                }
        }   else {
                    print("WCSession not supported!")
                    return false
            }
        return true
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        self.userLocation = CLLocation(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        
        if(!self.records.isEmpty) {
            // Sort records by distance
            self.records = sortRecords(self.records)
            if(userIsNearTheCamera == false) {
                // Find out if user is monitored by camera
                if (userDidEnterCameraRegion(camera: records[0])) {
                    userIsNearTheCamera = true
                    
                    createAndDismissAlert(alertTitle: "Be aware Camera!", alertMessage: records[0].meno!)
                    
                    createAndPresentLocalNotification(alerbody:  "Camera \(records[0].meno!) be aware!")
                    
                    if(enableSounds == true){ playSoundOnDispatchQueue() }
                }
            } else  { // user is in the camera region
                //User was in the camera region, now find out if he leaves the camera region
                if (userDidEnterCameraRegion(camera: records[0]) == false) {
                    //User leaves camera region
                    userIsNearTheCamera = false
                }
            }
        }
    }
    
    
    func createAndPresentLocalNotification(alerbody textToDisplay: String) {
        let note = UILocalNotification()
        note.alertBody = textToDisplay
        UIApplication.sharedApplication().presentLocalNotificationNow(note)
    }
    
    func  playSoundOnDispatchQueue() {
        
        let dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(dispatchQueue, {
            let mainBundle = NSBundle.mainBundle()
            
            /* Find the location of our file to feed to the audio player */
            let filePath = mainBundle.pathForResource("music", ofType:"mp3")
            
            if let path = filePath{
                let fileData = NSData(contentsOfFile: path)
                
                do {
                    /* Start the audio player */
                    self.audioPlayer = try AVAudioPlayer(data: fileData!)
                    guard let player = self.audioPlayer else{
                        return
                    }
                    
                    /* Set the delegate and start playing */
                    player.delegate = self
                    if player.prepareToPlay() && player.play(){
                        /* Successfully started playing */
                    } else {
                        print("fail to play")
                    }
                    
                } catch{
                    self.audioPlayer = nil
                    return
                }
            }
        })
    }
    
    //Create Alert view
    func createAndDismissAlert(alertTitle title:String, alertMessage message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        
        self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
        let delay = 3.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        })
    }
    
    // Determine if user is monitored by camera
    func userDidEnterCameraRegion(camera kamera: Kamera) -> Bool {
        
        let cameraLocation = CLLocation(latitude: kamera.latitude!.doubleValue,     longitude: kamera.longitude!.doubleValue)
        
        if(self.userLocation == nil){
            return false
        }
        
        if(userLocation?.distanceFromLocation(cameraLocation) < self.DistanceForNotifyUser ) {
            return true
        } else {
            return false
        }
    }


    func sortRecords(var records: [Kamera]) -> [Kamera] {
       
        records.sortInPlace({ (k1:Kamera, k2:Kamera) -> Bool in
            
            let cameraLocation1 = CLLocation(latitude: k1.latitude!.doubleValue,     longitude: k1.longitude!.doubleValue)
            let cameraLocation2 = CLLocation(latitude: k2.latitude!.doubleValue,     longitude: k2.longitude!.doubleValue)
            
            let distance1 = self.userLocation!.distanceFromLocation(cameraLocation1)
            let distance2 = self.userLocation!.distanceFromLocation(cameraLocation2)
            
            return distance1 < distance2
        })
        return records
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
      
    
}