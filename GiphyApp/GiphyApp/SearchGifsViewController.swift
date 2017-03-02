//
//  SearchGifsViewController.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class SearchGifsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingGifsIndicator: UIActivityIndicatorView!
    
    // we get it from the MainViewController
    var searchQuery: String = ""
    
    
    // object which have an array which stores trending gifs as GifObjects
    // also it performs updating of this array
    let searchQueryGifStorage = SearchQueryGifStorage()
    
    // constants
    let numberOfRowsInSection : Int = 1
    let heightForRowAt : CGFloat = 240.0
    let heightForFooterInSection : CGFloat = 30.0
    let trendedMarker : String = "trended!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        // UI setup
        UITableView.appearance().separatorColor = UIColor.black
        loadingGifsIndicator.hidesWhenStopped = true
        self.title = self.searchQuery
        
        // searchQueryGifStorage setup
        self.searchQueryGifStorage.setQuery(self.searchQuery)
        
        // first update
        updateGifs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // array of UIImages in gifStorage
        return self.searchQueryGifStorage.gifObjectsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightForRowAt
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.heightForFooterInSection
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // footer setup
        let footerView = UIView()
        footerView.backgroundColor = UIColor.white
        
        return footerView
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.imageView?.image = nil
        cell.textLabel?.text = ""
        
        if ( self.searchQueryGifStorage.gifObjectsArray[indexPath.section].imageData != nil){
            cell.imageView?.image = self.searchQueryGifStorage.gifObjectsArray[indexPath.section].imageData
        }
        
        /* if ever trended */
        if (self.searchQueryGifStorage.gifObjectsArray[indexPath.section].everTrended == true){
            cell.textLabel?.text = self.trendedMarker
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // when we reach the bottom of the screen
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
            if (!self.searchQueryGifStorage.isBusy()) {
                self.updateGifs()
            }
        }
    }
    
    func indicatorStopSpinning() {
        DispatchQueue.main.async() {
            self.loadingGifsIndicator.stopAnimating()
        }
    }
    
    func indicatorStartSpinning() {
        DispatchQueue.main.async() {
            self.loadingGifsIndicator.startAnimating()
        }
    }
    
    func updateGifs(){
        DispatchQueue.global(qos: .background).async {
            self.indicatorStartSpinning()
            self.searchQueryGifStorage.loadGifs()
            
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
            
            self.indicatorStopSpinning()
            
        }
    }
}
