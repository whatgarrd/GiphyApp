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
    var everTrended: Bool
    
    init(_ URL: String, _ everTrended: Bool ) {
        self.URL = URL
        self.everTrended = everTrended
    }
    
}
