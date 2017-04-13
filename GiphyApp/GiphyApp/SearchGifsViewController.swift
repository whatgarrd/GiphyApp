//
//  SearchGifsViewController.swift
//  GiphyApp
//
//  Created by Владислав Шарандин on 28.02.17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit
import NukeGifuPlugin

class SearchGifsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var tableView = UITableView()
    var loadingGifsIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let footerView = UIView(frame: CGRect.zero)
    let dummyFooterView = UIView(frame: CGRect.zero)
    
    // we get it from the MainViewController
    var searchQuery: String = ""
    
    let searchQueryGifStorage = GifStorage()
    
    let numberOfRowsInSection: Int = 1
    let heightForRowAt: CGFloat = 240.0
    let heightForFooterInSection: CGFloat = 30.0
    let trendedMarker: String = "trended!"
    let forCellReuseIdentifier: String = "Cell"
    
    override func loadView() {
        super.loadView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingGifsIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.addSubview(loadingGifsIndicator)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        
        tableView.allowsSelection = false
        
        footerView.addSubview(loadingGifsIndicator)
        
        loadingGifsIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingGifsIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            loadingGifsIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GifContainerCell.self, forCellReuseIdentifier: forCellReuseIdentifier)
        
        loadingGifsIndicator.hidesWhenStopped = true
        title = searchQuery
        
        searchQueryGifStorage.query = searchQuery
        
        updateGifs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchQueryGifStorage.gifObjects.count
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
        if section == tableView.numberOfSections - 1 {
            return footerView
        } else {
            return dummyFooterView
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GifContainerCell = tableView.dequeueReusableCell(withIdentifier: forCellReuseIdentifier, for: indexPath) as! GifContainerCell
        let urlString = searchQueryGifStorage.gifObjects[indexPath.section].URL
        
        AnimatedImage.manager.loadImage(with: URL(string: urlString)!, into: cell.innerImageView)
        
        // if ever trended
        if searchQueryGifStorage.gifObjects[indexPath.section].everTrended == true {
            cell.textLabel?.text = trendedMarker
        }

        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // when we reach the bottom of the screen
        if tableView.contentOffset.y >= (tableView.contentSize.height - tableView.frame.size.height) {
            if !searchQueryGifStorage.isBusy {
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
            if self.searchQueryGifStorage.loadGifs(true) {
                DispatchQueue.main.async() {
                    self.tableView.reloadData()
                }
                
            }
            
            self.indicatorStopSpinning()
        }
    }
}
