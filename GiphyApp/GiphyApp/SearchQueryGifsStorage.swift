//
//  SearchQueryGifsStorage.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import SwiftyJSON

class SearchQueryGifStorage {
    
    var gifObjectsArray = [GifObject]()
    
    private let downloadGroup = DispatchGroup()
    
    private var busy = false
    
    // giphy.com API parameters
    // after each update offset += updateSpeed
    private let limit: Int = 25
    private var offset: Int = 0
    private var query: String = ""
    private var rating: String = "pg"
    
    func loadGifs(){
        self.busy = true
        
        self.downloadGroup.enter()
        
        // asking api.giphy.com for images / using public key
        guard let url = URL(string: "http://api.giphy.com/v1/stickers/search?q=\(query)&api_key=dc6zaTOxFJmzC&limit=\(limit)&offset=\(offset)&rating=\(rating)")
            else {
                return
            }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            // Parsing JSON
            for counter in 0 ..< self.limit {
                let json = JSON(data: data)
                
                var everTrended = false
                
                let everTrendedPath: [JSONSubscriptType] = ["data",counter, "trending_datetime"]
                let urlPath: [JSONSubscriptType] = ["data", counter, "images", "fixed_width", "url"]
                
                // everTrended parse
                if let everTrendedJSON = json[everTrendedPath].string {
                    if everTrendedJSON != "1970-01-01 00:00:00" {
                        if everTrendedJSON != "0000-00-00 00:00:00" {
                            everTrended = true
                        }
                    }
                    
                } else {
                    print ("seems like everTrended parse had failed")
                }
                
                // URL parse
                if let url = json[urlPath].string {
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
            self.offset += self.limit
        }
        task.resume()
        
        let _ = downloadGroup.wait(timeout: DispatchTime.distantFuture)
        busy = false
    }
    
    func isBusy() -> Bool{
        return busy
    }

    func setQuery(_ query: String){
        self.query = query.replacingOccurrences(of: " ", with: "+")
    }
}
