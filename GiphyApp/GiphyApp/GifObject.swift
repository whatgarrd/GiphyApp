//
//  GifObject.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit


struct GifObject {
    var URL: String = ""
    var imageData: UIImage?
    var everTrended: Bool
    
    init(_ URL: String,_ imageData:UIImage,_ everTrended: Bool ) {
        self.URL = URL
        self.imageData = imageData
        self.everTrended = everTrended
    }
    
}
