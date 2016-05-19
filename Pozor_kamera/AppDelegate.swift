//
//  AppDelegate.swift
//
//  Created by Adam Sekeres on 9.2.2016.
//  Copyright © 2016 Adam Sekeres. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var tabBarViewController : ApplicationTabBarViewController?
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: nil))
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        // Create IMF Client Mobile Options from BlueMix
        IMFClient.sharedInstance().initializeWithBackendRoute("http://cameraapp.mybluemix.net", backendGUID: "7177d426-bc49-4c79-947b-bdc7e2f433a2")

        
        MQALogger.settings().reportOnShakeEnabled = true
        //Set the SDK mode Market for Production
        MQALogger.settings().mode = MQAMode.Market
        MQALogger.startNewSessionWithApplicationKey("1g1dcabedfeddaa0848f2795b0a8ab3b63395331edg0g2g5ef80e07")
        
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let locationManager = CLLocationManager()
        self.locationManager = locationManager
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let vc = ApplicationTabBarViewController()
        self.tabBarViewController = vc
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
}

