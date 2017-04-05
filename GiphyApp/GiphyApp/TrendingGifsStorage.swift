//
//  GifStorage.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import SwiftyJSON

class TrendingGifsStorage{
    
    var gifObjectsArray = [GifObject]()
    
    private let downloadGroup = DispatchGroup()
    
    private var busy = false
    
    // giphy.com API parameters
    private let limit: Int = 100
    private var offset: Int = 0
    
    // after each update offset += updateSpeed
    private let updateSpeed: Int = 5
    
    func loadGifs(){
        
        self.busy = true
        
        self.downloadGroup.enter()
        
        // asking api.giphy.com for images / using public key
        guard let url = URL(string: "http://api.giphy.com/v1/stickers/trending?api_key=dc6zaTOxFJmzC&limit=\(self.limit)&offset=\(self.offset)")
            else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            guard let dataFromNetworking = data else {
                print("Data is empty")
                return
            }
            
            // Parsing JSON
            
            for counter in 0 ..< self.limit {
                
                let json = JSON(data: dataFromNetworking)

                
                var everTrended = false
             
                let everTrendedPath: [JSONSubscriptType] = ["data",counter, "trending_datetime"]
                let urlPath: [JSONSubscriptType] = ["data", counter, "images", "fixed_width", "url"]
                
                // everTrended parse
                if let everTrendedJSON = json[everTrendedPath].string {
                    if(everTrendedJSON != "1970-01-01 00:00:00"){
                        everTrended = true
                    }
                    
                } else {
                    print ("seems like everTrended parse had failed")
                }
                
                
                // URL parse
                if let url = json[urlPath].string {
                    
                    // retrieving image by url
                    //let imageData =  try! Data(contentsOf: URL(string:url)!)
                    
                    // creating and filling GifObject with parsed information
                    let justAnotherGifObject = GifObject(url, everTrended)
                    
                    // storing GifObject in array
                    self.gifObjectsArray.append(justAnotherGifObject)
                    
                } else {
                    print("seems like url parse had failed")
                }
                
             
            }
            self.downloadGroup.leave()
            
            // API parameter update
            self.offset += self.updateSpeed
        }
        task.resume()
        
        let _ = downloadGroup.wait(timeout: DispatchTime.distantFuture)
        
        self.busy = false
    }
    
    func isBusy() -> Bool{
        return self.busy
    }
    
}

