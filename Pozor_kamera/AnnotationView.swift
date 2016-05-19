//
//  AnnotationView.swift
//  mapka22.12
//
//  Created by Adam Sekeres on 27.1.2016.
//  Copyright © 2016 Adam Sekeres. All rights reserved.
//

import UIKit
import MapKit

class AnnotationView: MKAnnotationView {

   override init(frame: CGRect)
    {
        super.init(frame: frame)
        let img = UIImage(named: "cameraImage")
        let imgView = UIImageView(image: img)
        imgView.frame = CGRectMake(-10, -10, 20, 20)
        self.addSubview(imgView)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
}
