//
//  PostEditorImageCell.swift
//  Graygram
//
//  Created by Dev.MJ on 15/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class PostEditorImageCell: UITableViewCell {
  
  //UICollectionViewCell은 기본 object가 없지만, UITAbleViewCell은 기본 object가 있다.
  //fileprivate let imageView: UIImageView  그래서 이렇게 못씀.
  fileprivate let photoView = UIImageView()
  
  //tableViewCell의 생성자
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.contentView.addSubview(self.photoView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(image: UIImage){
    self.photoView.image = image
  }
  
  //collectionView에서는 size반환, tableView에서는 height만 반환(width는 꽉차니까)
  class func height(width: CGFloat) -> CGFloat {
    return width  //정사각형이므로
  }
  
  override func layoutSubviews(){
    super.layoutSubviews()
    self.photoView.frame = self.contentView.bounds
  }
}
