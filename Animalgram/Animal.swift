//
//  Animal.swift
//  Animalgram
//
//  Created by NPappas on 12/15/16.
//  Copyright © 2016 Nick Pappas. All rights reserved.
//

import UIKit

class Animal: NSObject, NSCoding
{
    var photoTitle : String
    var image : UIImage
    
    init(photoTitle : String, image : UIImage)
    {
        self.photoTitle = photoTitle
        self.image = image
    }
    
    //Initializer used when loading objects of the class
    required init?(coder aDecoder: NSCoder)
    {
        photoTitle = aDecoder.decodeObject(forKey: "photoTitle") as! String
        image = aDecoder.decodeObject(forKey: "image") as! UIImage
    }
    
    //Used for saving
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(photoTitle, forKey: "photoTitle")
        aCoder.encode(image, forKey: "image")
    }
}
