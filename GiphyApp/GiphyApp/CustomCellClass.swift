//
//  CustomCellClass.swift
//  GiphyApp
//
//  Created by Sharandin, Vladislav on 4/4/17.
//  Copyright © 2017 Владислав Шарандин. All rights reserved.
//

import Foundation

import AlamofireImage
import UIKit

class CustomCell : UITableViewCell {
    
    var whateverImageView = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        whateverImageView.contentMode = .scaleAspectFit
        
        whateverImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(whateverImageView)
        
        NSLayoutConstraint.activate([
            whateverImageView.rightAnchor.constraint(equalTo: self.rightAnchor),
            whateverImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            whateverImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
            whateverImageView.topAnchor.constraint(equalTo: self.topAnchor),
            
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
