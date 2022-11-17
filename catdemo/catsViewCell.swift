//
//  catsViewCell.swift
//  catdemo
//
//  Created by Justin Brady on 11/11/22.
//

import Foundation
import UIKit

class CatsViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let rect = CGRect(x: 0, y: 0, width: width, height: height)
//        self.frame = rect
        
        contentView.backgroundColor = UIColor.green
        myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

        myImageView.image = UIImage(systemName: "ellipses")
        contentView.addSubview(myImageView)
        
        // constraints to indicate cell size to collection view
        //contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
        //contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
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
