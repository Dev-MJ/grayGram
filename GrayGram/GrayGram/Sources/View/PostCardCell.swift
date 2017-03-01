//
//  PostCardCell.swift
//  GrayGram
//
//  Created by Dev.MJ on 01/03/2017.
//  Copyright © 2017 HelloMJ. All rights reserved.
//

import UIKit

class PostCardCell: UICollectionViewCell {
  
  fileprivate let postImageView = UIImageView()
  fileprivate let userImageView = UIImageView()
  
  struct Metric {
    static let userImageViewTop = CGFloat(10)
    static let userImageViewLeft = CGFloat(10)
    static let userImageViewWidth = CGFloat(30)
    static let userImageViewHeight = CGFloat(30)
    
    static let postImageViewTop = CGFloat(10)
    static let postImageViewLeft = CGFloat(0)
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.contentView.backgroundColor = .white
    self.userImageView.backgroundColor = .lightGray
    self.postImageView.backgroundColor = .lightGray
    
    self.contentView.addSubview(self.userImageView)
    self.contentView.addSubview(self.postImageView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func congifure(post: Post){
    self.userImageView.setKfImage(photoID: post.userPhotoID)
    self.postImageView.setKfImage(photoID: post.photoID)
    self.setNeedsLayout()
  }
  
  override func layoutSubviews(){
    
    self.userImageView.top = Metric.userImageViewTop
    self.userImageView.left = Metric.userImageViewLeft
    self.userImageView.width = Metric.userImageViewWidth
    self.userImageView.height = Metric.userImageViewHeight
    
    self.postImageView.top = self.userImageView.bottom + Metric.postImageViewTop
    self.postImageView.left = Metric.postImageViewLeft
    self.postImageView.width = self.contentView.width
    self.postImageView.height = self.postImageView.width
  }
  
  class func size(width: CGFloat) -> CGSize{
    
    var height: CGFloat = 0
    height += Metric.userImageViewTop
    height += Metric.userImageViewHeight
    height += Metric.postImageViewTop
    height += width
    
    return CGSize(width: width, height: height)
  }
}
