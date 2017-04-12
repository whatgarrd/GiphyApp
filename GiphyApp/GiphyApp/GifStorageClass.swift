//
//  GifStorage.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import SwiftyJSON

class GifStorage {
    
    // GifObject contains URL as url string and bool everTrended
    var gifObjectsArray = [GifObject]()
    
    // sync section
    let downloadGroup = DispatchGroup()
    private var busy = false
    
    // giphy.com API parameters
    // after each update offset += limit
    private let limit: Int = 25
    private var offset: Int = 0
    
    // additional parameters go for search request
    private var query: String = ""
    private var rating: String = "pg"
    
    // default -- false -- goes for trending gifs parse
    func loadGifs(_ isItSearchRequest: Bool = false) {
        //prevent requests while busy
        if busy {
            print("Storage is busy, not right now.")
            return
        }
        
        // can't access method again from now on
        busy = true
        downloadGroup.enter()
        
        // url value depends of isItSearchRequest value
        // false means trending gifs, true -- gifs by search request
        guard let url: URL = self.calculateURL(isItSearchRequest) else {
            return
        }
        
        // attempt to get data as JSON
        getGifDataAsJSON(url) { json in
            if let json = json {
                // and parse it
                // here we fill gifObjectsArray
                self.parseJSONToGifObjectsArray(json)
            }
            
            // can access again
            self.downloadGroup.leave()
            self.busy = false
        }

        let _ = downloadGroup.wait(timeout: DispatchTime.distantFuture)
    }
    
    func isBusy() -> Bool {
        return busy
    }
    
    private func getGifDataAsJSON(_ url: URL, completionHandler: @escaping ((JSON?)->())) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print(error as Any)
                return
            }
            
            guard data != nil else {
                print("Data is empty")
                return
            }
            
            if data != nil {
                // API parameter update
                self.offset += self.limit
                
                //parse JSON to gifObjectsArray finally
                completionHandler(JSON(data as Any))
            }
        }
        task.resume()
    }
    
    private func parseJSONToGifObjectsArray(_ JSONData: JSON) {
        // Parsing JSON
        for counter in 0 ..< self.limit {
            var everTrended = false
            
            let everTrendedPath: [JSONSubscriptType] = ["data",counter, "trending_datetime"]
            let urlPath: [JSONSubscriptType] = ["data", counter, "images", "fixed_width", "url"]
            
            // everTrended parse
            if let everTrendedJSON = JSONData[everTrendedPath].string {
                if(everTrendedJSON != "1970-01-01 00:00:00") {
                    if everTrendedJSON != "0000-00-00 00:00:00"{
                        everTrended = true
                    }
                }

            } else {
                print ("seems like everTrended parse had failed")
            }
            
            // URL parse
            if let url = JSONData[urlPath].string {
                // creating and filling GifObject with parsed information
                let justAnotherGifObject = GifObject(url, everTrended)
                
                // storing GifObject in array finally
                self.gifObjectsArray.append(justAnotherGifObject)
                
            } else {
                print("seems like url parse had failed")
            }
        }
    }
    
    private func calculateURL(_ isItSearchRequest: Bool) -> URL? {
        if  isItSearchRequest == false {
            // asking api.giphy.com for trending images / using public key
            guard let url = URL(string: "http://api.giphy.com/v1/stickers/trending?api_key=dc6zaTOxFJmzC&limit=\(limit)&offset=\(offset)")
                else {
                    return nil
                }
            
            return url

        } else {
            // if isItSearchRequest == true, actually
            // asking for images with search queary / using public key still
            guard let url = URL(string: "http://api.giphy.com/v1/stickers/search?q=\(query)&api_key=dc6zaTOxFJmzC&limit=\(limit)&offset=\(offset)&rating=\(rating)")
                else {
                    return nil
                }
            
            return url
        }
    }

    
    // query setup
    // replacing empty spaces with "+" character.
    func setQuery(_ query: String){
        self.query = query.replacingOccurrences(of: " ", with: "+")
    }
}
