//
//  catsViewCell.swift
//  catdemo
//
//  Created by Justin Brady on 11/11/22.
//

import Foundation
import UIKit

class CatsViewCell: UICollectionViewCell {
    
    let width = 84.0
    let height = 84.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = rect
        
        myImageView = UIImageView(frame: rect)

        contentView.addSubview(myImageView)
        
        // constraints to indicate cell size to collection view
        contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
//        contentView.leadingAnchor.constraint(equalTo: myImageView.leadingAnchor).isActive = true
//        contentView.trailingAnchor.constraint(equalTo: myImageView.trailingAnchor).isActive = true
//        contentView.topAnchor.constraint(equalTo: myImageView.topAnchor).isActive = true
//        contentView.bottomAnchor.constraint(equalTo: myImageView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView {
        get {
            return myImageView
        }
    }
    
    private var myImageView = UIImageView()
}
