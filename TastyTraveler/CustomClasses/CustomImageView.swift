//
//  CustomImageView.swift
//  TastyTraveler
//
//  Created by Michael Bart on 3/15/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {

    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String, placeholder: UIImage?) {
        lastURLUsedToLoadImage = urlString
        
        if let placeholder = placeholder {
            self.image = placeholder
        } else {
            self.image = nil
        }
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch image: ", error)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.alpha = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
                self.image = photoImage
            }
        }.resume()
    }

}
