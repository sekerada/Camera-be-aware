//
//  Kamera.swift
//  semestralkaBluemix
//
//  Created by Adam Sekeres on 9.2.2016.
//  Copyright © 2016 Adam Sekeres. All rights reserved.
//

import Foundation

class Kamera{
    
    var id: NSNumber!
    var latitude: NSNumber!
    var longitude: NSNumber!
    var meno: String!
    
    init(name meno:String , id id:NSNumber , longitude lon: NSNumber, latitude lat:NSNumber){
        self.id = id
        self.latitude = lat
        self.longitude = lon
        self.meno = meno
    }
}