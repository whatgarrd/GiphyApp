//
//  ViewController.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import NukeGifuPlugin

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var tableView = UITableView()
    var searchBar = UISearchBar()
    var loadingGifsIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let footerView = UIView(frame: CGRect.zero)
    let dummyFooterView = UIView(frame: CGRect.zero)
    
    // constants
    let numberOfRowsInSection: Int = 1
    let heightForRowAt: CGFloat = 240.0
    let heightForFooterInSection: CGFloat = 30.0
    let titleString: String = "Trending"
    let searchGifsSegueIdentifier: String = "Search"
    let forCellReuseIdentifier: String = "Cell"
    let viewTopAnchorConst: CGFloat = 20.0
    let viewBottomAnchorConst: CGFloat = 70.0
    
    // object which have an array which stores trending gifs as GifObjects
    // also it performs updating of this array
    let trendingGifsStorage = TrendingGifsStorage()

    override func loadView() {
        super.loadView()
        
        //preset
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        loadingGifsIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        tableView.addSubview(loadingGifsIndicator)
        view.addSubview(tableView)
        
        //searchBar setup
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: viewTopAnchorConst),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchBar.bottomAnchor.constraint(equalTo: view.topAnchor, constant: viewBottomAnchorConst)
            
        ])
        
        //tableView setup
        NSLayoutConstraint.activate([
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
        ])
        
        tableView.allowsSelection = false
        
        //footerView setup
        footerView.addSubview(loadingGifsIndicator)
        
        //loadingGifsIndicator setup
        loadingGifsIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingGifsIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            loadingGifsIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView  and searchBar setup
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //register custom cell
        tableView.register(GifContainerCell.self, forCellReuseIdentifier: forCellReuseIdentifier)

        // additional UI setup
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
        let cell: GifContainerCell = tableView.dequeueReusableCell(withIdentifier: forCellReuseIdentifier, for: indexPath) as! GifContainerCell
        let urlString = trendingGifsStorage.gifObjectsArray[indexPath.section].URL
        
        AnimatedImage.manager.loadImage(with: URL(string: urlString)!, into: cell.innerImageView)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForRowAt
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return heightForFooterInSection
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //last section
        if section == tableView.numberOfSections - 1 {
            return footerView
        } else {
            return dummyFooterView
        }
    }

    func updateGifs() {
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
