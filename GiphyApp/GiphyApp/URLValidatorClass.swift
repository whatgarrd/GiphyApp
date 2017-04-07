//
//  URLValidatorClass.swift
//  GiphyApp
//
//  Created by Sharandin, Vladislav on 4/7/17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit

class URLValidator {
    
    //http://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
    static func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}
