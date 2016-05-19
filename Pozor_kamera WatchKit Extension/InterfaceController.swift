//
//  InterfaceController.swift
//  appleWatchExtension Extension
//
//  Created by Adam Sekeres on 25.2.2016.
//  Copyright © 2016 Adam Sekeres. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController,WCSessionDelegate {
    
    @IBOutlet var informationLabel: WKInterfaceLabel!
    
    @IBOutlet var table: WKInterfaceTable!
    var session : WCSession!
    
    
    var cameras = [("K1" , 5.2) ,("K2", 25.2) ,("K3", 35.2) , ("K4", 555.2) ]
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        self.session = WCSession.defaultSession()
        self.session.delegate = self
        self.session.activateSession()
        
        self.table.setNumberOfRows(1, withRowType: "CameraRowIdentifier")
        self.informationLabel.setText("Out of sync")
        let theRow = self.table.rowControllerAtIndex(0) as! CameraRow
        theRow.cameraRowTextLabel.setText("Please synchronize with")
        theRow.cameraRowDetailTextLabel.setText("your mobile phone")
        theRow.cameraRowImage.setImage(UIImage(named: "warningImage.png"))
        
    }
    
    

    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        self.informationLabel.setText("The nearest cams")
        if  let dataFromPhone = message["cameraRecords"] as? [NSDictionary] {
            self.table.setNumberOfRows(9, withRowType: "CameraRowIdentifier")
            
            for index in 0..<dataFromPhone.count {
                let theRow = self.table.rowControllerAtIndex(index) as! CameraRow
                let dict = dataFromPhone[index]
                theRow.cameraRowImage.setImage(UIImage(named: "80x80cameraimage.png"))
                if let name = dict["meno"] as? String {
                    if let distance = dict["distance"] as? Double {
                        
                        theRow.cameraRowTextLabel.setText(name)
                        
                        if distance < 1000 {
                            theRow.cameraRowDetailTextLabel.setText(String.localizedStringWithFormat("%.1f m.", distance))
                        } else {
                            theRow.cameraRowDetailTextLabel.setText(String.localizedStringWithFormat("%.2f km.", distance/1000))
                        }
                    }
                }
                
            }
        }
        
        
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
