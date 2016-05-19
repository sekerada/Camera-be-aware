//
//  ApplicationTabBarViewController.swift
//  mapka22.12
//
//  Created by Adam Sekeres on 26.12.2015.
//  Copyright © 2015 Adam Sekeres. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ApplicationTabBarViewController: UITabBarController , SettingsDelegate , RecordsDelegate {

   
    weak var timer : NSTimer!
    var MapVC: MapViewController!
    var DistanceTableVC: DistanceTableViewController?
    var OptionsVC: OptionsViewController?
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    override func loadView() {
   
        super.loadView()
        
        let item1 = MapViewController()
        let item2 = DistanceTableViewController()
        let item3 = OptionsViewController()
      
        let icon1 = UITabBarItem(title: "Map", image: UIImage(named: "map-pin"), tag: 1)
        let icon2 = UITabBarItem(title: "Cameras", image:UIImage(named: "camera"), tag: 2)
        let icon3 = UITabBarItem(title: "Settings", image:UIImage(named: "spanner"), tag: 3)
        
        self.MapVC = item1
        self.DistanceTableVC = item2
        self.OptionsVC = item3
        
        item1.tabBarItem = icon1
        item2.tabBarItem = icon2
        item3.tabBarItem = icon3

        item3.delegate = self
        item1.delegate = self
        let controllers = [item1,item2,item3]
        //array of the root view controllers displayed by the tab bar interface
        self.viewControllers = controllers
    }

    override func viewDidLoad() {
        
        //Refresh data every 2 second
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateUserLocation:", userInfo: nil, repeats: true)
        self.timer = timer
    }
    
    
    func updateUserLocation(timer:NSTimer) {
        if let newValue = self.MapVC?.userLocation {
                if let vc2 = self.DistanceTableVC {
                        if let _ = vc2.userLocation {
                            vc2.userLocation = newValue
                        }
                        else {
                            let newValue = CLLocation()
                            vc2.userLocation = newValue
                        }
                }
         }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Delegate functions
    func userChangedStepperValue(value: Double) {
        if(self.MapVC != nil){
            self.MapVC.DistanceForNotifyUser = value
        }
    }
    
    func userChangedSwitchValue(value: Bool) {
        if (self.MapVC != nil) {
            self.MapVC.enableSounds = value
        }
    }
    
    func getDataFromBluemix(data records: [Kamera]) {
        if(self.DistanceTableVC != nil){
            self.DistanceTableVC?.records = records
        }
    }
}