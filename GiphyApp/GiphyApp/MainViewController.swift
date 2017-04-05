//
//  ViewController.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import SwiftGifOrigin
import AlamofireImage

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingGifsIndicator: UIActivityIndicatorView!
    
    // constants
    let numberOfRowsInSection : Int = 1
    let heightForRowAt : CGFloat = 240.0
    let heightForFooterInSection : CGFloat = 30.0
    let titleString: String = "Trending"
    let searchGifsSegueIdentifier = "GoToSearch"
    
    // object which have an array which stores trending gifs as GifObjects
    // also it performs updating of this array
    let trendingGifsStorage = TrendingGifsStorage()
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView  and searchBar setup
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //register custom cell
        self.tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")


        // UI setup
        UITableView.appearance().separatorColor = UIColor.black
        loadingGifsIndicator.hidesWhenStopped = true
        self.title = titleString
        
        // first update
        updateGifs()
  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // array of UIImages in gifStorage
        return self.trendingGifsStorage.gifObjectsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRowsInSection
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CustomCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        
        let placeholderImage = UIImage(named: "placeholder")!
        
        let url = URL(string: self.trendingGifsStorage.gifObjectsArray[indexPath.section].URL)!
   
        cell.whateverImageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        
        return cell
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

    func updateGifs(){
        DispatchQueue.global(qos: .background).async {
            self.indicatorStartSpinning()
            self.trendingGifsStorage.loadGifs()
            
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
            
            self.indicatorStopSpinning()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // when we reach the bottom of the screen
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
            if (!self.trendingGifsStorage.isBusy()) {
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: self.searchGifsSegueIdentifier, sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == searchGifsSegueIdentifier) {
            let SearchGifsViewController = (segue.destination as! SearchGifsViewController)
            SearchGifsViewController.searchQuery  = self.searchBar.text!
        }
    }
}

