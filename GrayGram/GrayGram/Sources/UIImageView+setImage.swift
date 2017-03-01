//
//  UIImageView+setImage.swift
//  GrayGram
//
//  Created by Dev.MJ on 01/03/2017.
//  Copyright © 2017 HelloMJ. All rights reserved.
//

import Kingfisher

extension UIImageView {
  
  func setKfImage(photoID: String){
    guard let url = URL(string: "https://graygram.com/photos/\(photoID)/600x600") else {
      self.image = nil
      return
    }
    self.kf.setImage(with: url)
  }
}
