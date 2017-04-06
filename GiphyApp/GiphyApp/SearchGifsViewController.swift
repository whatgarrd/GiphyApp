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
    let numberOfRowsInSection: Int = 1
    let heightForRowAt: CGFloat = 240.0
    let heightForFooterInSection: CGFloat = 30.0
    let trendedMarker: String = "trended!"
    let forCellReuseIdentifier: String = "Cell"
    let placeholderName: String = "placeholder"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        //register custom cell
        tableView.register(gifContainerCell.self, forCellReuseIdentifier: forCellReuseIdentifier)
        
        // UI setup
        UITableView.appearance().separatorColor = UIColor.black
        loadingGifsIndicator.hidesWhenStopped = true
        title = searchQuery
        
        // searchQueryGifStorage setup

        searchQueryGifStorage.setQuery(searchQuery)
        
        // first update
        updateGifs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // array of UIImages in gifStorage
        return searchQueryGifStorage.gifObjectsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // footer setup
        let footerView = UIView()
        footerView.backgroundColor = UIColor.white
        
        return footerView
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: gifContainerCell = tableView.dequeueReusableCell(withIdentifier: forCellReuseIdentifier, for: indexPath) as! gifContainerCell
        let placeholderImage = UIImage(named: placeholderName)!
        guard let url = URL(string: searchQueryGifStorage.gifObjectsArray[indexPath.section].URL) else {
            return cell
        }
        
        cell.innerImageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        
        // if ever trended
        if searchQueryGifStorage.gifObjectsArray[indexPath.section].everTrended == true {
            cell.textLabel?.text = trendedMarker
        }

        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // when we reach the bottom of the screen
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
            if !searchQueryGifStorage.isBusy() {
                updateGifs()
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
