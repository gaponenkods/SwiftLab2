//
//  ExtensionUIImage.swift
//  Lab2
//
//  Created by Konstantyn Byhkalo on 1/23/17.
//  Copyright © 2017 Gaponenko Dmitriy. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func isEqualToImage(image: UIImage?) -> Bool {
        if let image = image {
            let data1: NSData = UIImagePNGRepresentation(self)! as NSData
            let data2: NSData = UIImagePNGRepresentation(image)! as NSData
            return data1.isEqual(data2)
        } else {
            return false
        }
    }
    
}
