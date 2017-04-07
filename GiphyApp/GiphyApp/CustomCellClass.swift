//
//  CustomCellClass.swift
//  GiphyApp
//
//  Created by Sharandin, Vladislav on 4/4/17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import UIKit

import Nuke
import NukeGifuPlugin

class gifContainerCell: UITableViewCell {

    private let placeholderName: String = "placeholder"
    
    var innerImageView = AnimatedImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        innerImageView.contentMode = .scaleAspectFit
        innerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(innerImageView)
        
        NSLayoutConstraint.activate([
            innerImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            innerImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            innerImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            innerImageView.topAnchor.constraint(equalTo: self.topAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        innerImageView.prepareForReuse()
    }
}
