//
//  Pozor_kameraTests.swift
//  Pozor_kameraTests
//
//  Created by Adam Sekeres on 18.3.2016.
//  Copyright © 2016 Adam Sekeres. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Pozor_kamera

class Pozor_kameraTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddAnotationsToMapViewMethod() {
        
        let vc = MapViewController()
        vc.loadView()
        let  response = vc.addAnnotationsToMapView()
        XCTAssertFalse(response, "addAnnotationsToMapView return true, should return false!")
        
        let camera = Kamera(name: "Camera1", id: 1, longitude: 51.5, latitude: 51.4)
        vc.records.append(camera)
        let response2 = vc.addAnnotationsToMapView()
        XCTAssertTrue(response2)
    }
    
    
    func testSendDataToAppleWatchMethod() {
        let vc = MapViewController()
        vc.records.removeAll()
        XCTAssertFalse(vc.sendDataToAppleWatch(dataToSend: vc.records))
        
        let camera = Kamera(name: "TestCamera", id: 1, longitude: 51.5, latitude: 51.4)
        vc.records.append(camera)
        vc.userLocation = CLLocation(latitude: 50, longitude: 51.1)
        XCTAssertTrue(vc.sendDataToAppleWatch(dataToSend: vc.records))
        
        vc.userLocation = nil
        XCTAssertFalse(vc.sendDataToAppleWatch(dataToSend: vc.records))
    }
    
    func testUserDidEnterCameraRegionMethod() {
        let vc = MapViewController()
        vc.DistanceForNotifyUser = 100.0
        let camera = Kamera(name: "Camera1", id: 1, longitude: 51.5555, latitude: 51.4444)
        vc.userLocation = nil
        XCTAssertFalse(vc.userDidEnterCameraRegion(camera: camera))
        
        vc.userLocation = CLLocation(latitude: 51.4444, longitude: 51.5554)
        XCTAssertTrue(vc.userDidEnterCameraRegion(camera: camera))
    }
    
    func testDelegateMethods() {
        
        let vc = ApplicationTabBarViewController()
        vc.OptionsVC?.viewDidLoad()
        vc.OptionsVC?.MyStepper?.value = 250
        vc.OptionsVC?.stepperChanged((vc.OptionsVC?.MyStepper)!)
        
        XCTAssertEqual(vc.OptionsVC?.MyStepper?.value, vc.MapVC.DistanceForNotifyUser)
        
        vc.OptionsVC?.MySwitch?.setOn(false, animated: false)
        vc.OptionsVC?.switchChanged((vc.OptionsVC?.MySwitch)!)
        XCTAssertEqual(vc.OptionsVC?.MySwitch?.on, vc.MapVC.enableSounds)
    }
    
    
    
    func  testApplicationTabBarControllers(){
        let vc = ApplicationTabBarViewController()
        XCTAssertNotNil(vc.MapVC, "MapVC is nil!")
        XCTAssertNotNil(vc.DistanceTableVC, "DistanceTableVC is nil!")
        XCTAssertNotNil(vc.OptionsVC, "OptionsVC is nil!")
    }
    
}
