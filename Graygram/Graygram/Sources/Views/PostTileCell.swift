//
//  PostTileCell.swift
//  Graygram
//
//  Created by Dev.MJ on 22/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class PostTileCell: UICollectionViewCell {
  
  fileprivate let photoView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.photoView.backgroundColor = .lightGray
    self.contentView.addSubview(self.photoView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(post: Post){
    self.photoView.setImage(with: post.photoID)
  }
  
  class func size(width: CGFloat, post: Post) -> CGSize {
    return CGSize(width: width, height: width)
  }
  
  override func layoutSubviews() {
//    self.photoView.width = self.contentView.width
//    self.photoView.height = self.contentView.height
//    self.photoView.center = self.contentView.center
    self.photoView.frame = self.contentView.bounds
  }
  
}
