//
//  ViewController.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import Gifu

import Nuke
import NukeGifuPlugin

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingGifsIndicator: UIActivityIndicatorView!
    
    // constants
    let numberOfRowsInSection: Int = 1
    let heightForRowAt: CGFloat = 240.0
    let heightForFooterInSection: CGFloat = 30.0
    let titleString: String = "Trending"
    let searchGifsSegueIdentifier: String = "GoToSearch"
    let forCellReuseIdentifier: String = "Cell"
    let placeholderName: String = "placeholder"
    
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
        tableView.register(gifContainerCell.self, forCellReuseIdentifier: forCellReuseIdentifier)

        // UI setup
        UITableView.appearance().separatorColor = UIColor.black
        loadingGifsIndicator.hidesWhenStopped = true
        title = titleString
        
        // first update
        updateGifs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // array of UIImages in gifStorage
        return trendingGifsStorage.gifObjectsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: gifContainerCell = tableView.dequeueReusableCell(withIdentifier: forCellReuseIdentifier, for: indexPath) as! gifContainerCell
        
        let urlString = trendingGifsStorage.gifObjectsArray[indexPath.section].URL
   
        //if we can access
        if URLValidator.verifyUrl(urlString: urlString) {
            AnimatedImage.manager.loadImage(with: URL(string: urlString)!, into: cell.innerImageView)
        }
        return cell
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
            if !trendingGifsStorage.isBusy() {
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: self.searchGifsSegueIdentifier, sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == searchGifsSegueIdentifier {
            let searchGifsViewController = segue.destination as! SearchGifsViewController
            if searchBar.text != nil {
                searchGifsViewController.searchQuery = searchBar.text!
            }
        }
    }
}
