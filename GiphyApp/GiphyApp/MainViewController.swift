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
    
    // Constants
    let numberOfRowsInSection = 1
    let heightForRowAt: CGFloat = 240.0
    let heightForFooterInSection: CGFloat = 30.0
    let titleString = "Trending"
    let forCellReuseIdentifier = "Cell"
    let searchBarBottomAnchor: CGFloat = 50.0
    
    let trendingGifStorage = GifStorage()
    
    var indicatorCounter = 0

    override func loadView() {
        super.loadView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        loadingGifsIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchBar.bottomAnchor.constraint(equalTo: view.topAnchor, constant: searchBarBottomAnchor)
            
        ])
        
        NSLayoutConstraint.activate([
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
        ])
        
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        
        footerView.addSubview(loadingGifsIndicator)
        
        NSLayoutConstraint.activate([
            loadingGifsIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            loadingGifsIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.register(GifContainerCell.self, forCellReuseIdentifier: forCellReuseIdentifier)

        loadingGifsIndicator.hidesWhenStopped = true
        title = titleString
        
        updateGifs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return trendingGifStorage.gifObjects.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GifContainerCell = tableView.dequeueReusableCell(withIdentifier: forCellReuseIdentifier, for: indexPath) as! GifContainerCell
        let urlString = trendingGifStorage.gifObjects[indexPath.section].URL
        
        if let imageURL = URL(string: urlString) {
            AnimatedImage.manager.loadImage(with: imageURL, into: cell.innerImageView)
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
        if section == tableView.numberOfSections - 1 {
            return footerView
        } else {
            return dummyFooterView
        }
    }

    func updateGifs() {
        self.indicatorStartSpinning()
        if !trendingGifStorage.isBusy{
            trendingGifStorage.loadGifs() { success in
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
                self.indicatorStopSpinning()
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // when we reach the bottom of the screen
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
                updateGifs()
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
            let searchGifsViewController = SearchGifsViewController()
            
            if let searchBarText = searchBar.text {
                searchGifsViewController.searchQuery = searchBarText
            }
            
            self.navigationController?.pushViewController(searchGifsViewController, animated: true)
        }
    }
}
