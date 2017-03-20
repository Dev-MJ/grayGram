//
//  CollectionActivityIndicatorView.swift
//  Graygram
//
//  Created by Dev.MJ on 27/02/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

// ⭐️ final
final class CollectionActivityIndicatorView: UICollectionReusableView {
  
  fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  // ⭐️
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.startAnimating()
  }
  
  //스토리 보드 안쓰므로 내부를 굳이 구현할 필요는 없다.
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.activityIndicatorView.centerX = self.width / 2
    self.activityIndicatorView.centerY = self.height / 2
  }
  
}
