//
//  catCard.swift
//  catdemo
//
//  Created by Justin Brady on 11/14/22.
//

import Foundation
import UIKit

class CatCard: NSObject {
    
    var image: UIImage = UIImage()
    var id: URL!
    
    override init() {
        super.init()
        
        URLSession.shared.downloadTask(with: URLRequest(url: URL(string: "https://cataas.com/cat")!), completionHandler: {
            [weak self] optUrlToFile, optResponse, optError in
            
            guard let urlToFile = optUrlToFile
                else {
                fatalError()
            }
            
            if let data = try? Data(contentsOf: urlToFile) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2) { [weak self] in
                    // try and decode image again with more data
                    if let img = UIImage(data: data) {
                        self?.image = img
                    }
                    else {
                        fatalError()
                    }
                    self?.id = urlToFile
                }
            }
            else {
                fatalError()
            }
        }).resume()
    }
}
