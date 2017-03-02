//
//  SearchQueryGifsStorage.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class SearchQueryGifStorage{
    
    var gifObjectsArray = [GifObject]()
    
    private let downloadGroup = DispatchGroup()
    
    private var busy = false
    
    /* giphy.com API parameters */
    private let limit: Int = 5
    private var offset: Int = 0
    private var query: String = ""
    private var rating: String = "pg"
    
    /* after each update offset += updateSpeed */
    private let updateSpeed: Int = 5
    
    
    func loadGifs(){
        
        self.busy = true
        
        self.downloadGroup.enter()
        
        // asking api.giphy.com for images / using public key
        guard let url = URL(string: "http://api.giphy.com/v1/stickers/search?q=\(self.query)&api_key=dc6zaTOxFJmzC&limit=\(self.limit)&offset=\(self.offset)&rating=\(self.rating)")
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
            let json = try! JSONSerialization.jsonObject(with: data, options: [])  as! [String:Any]
            

            for counter in 0 ..< self.limit {
                let JSONDataArray = json["data"] as! [[String : Any]]
                // prevent IndexOutOfRange error
                if (JSONDataArray.count - 1 < counter){
                    break
                }
                let JSONDataObject = JSONDataArray[counter]
                let JSONImagesObject = JSONDataObject["images"] as! [String:Any]
                let JSONFixedWidthObject = JSONImagesObject["fixed_width"] as! [String:Any]
                
                let JSONTrendingDatetime = JSONDataObject["trending_datetime"] as! String

                var everTrended = false
                if((JSONTrendingDatetime != "1970-01-01 00:00:00") && (JSONTrendingDatetime != "0000-00-00 00:00:00")){
                    everTrended = true
                }
                
                if let url = JSONFixedWidthObject["url"] as? String {

                    // retrieving image by url
                    let imageData =  try! Data(contentsOf: URL(string:url)!)
                    
                    // creating and filling GifObject with parsed information
                    let justAnotherGifObject = GifObject(url, UIImage.gif(data: imageData)!, everTrended)
                    
                    // storing GifObject in array
                    self.gifObjectsArray.append(justAnotherGifObject)
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

    func setQuery(_ query: String){
        self.query = query.replacingOccurrences(of: " ", with: "+")
    }
}
