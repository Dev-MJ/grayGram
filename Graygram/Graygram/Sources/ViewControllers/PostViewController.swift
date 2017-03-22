//
//  PostViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 22/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class PostViewController: UIViewController {
  
  fileprivate let post: Post
  fileprivate let collectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: UICollectionViewLayout())
  
  init(post: Post) {
    self.post = post
    super.init(nibName: nil, bundle: nil)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.backgroundColor = .yellow
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "postCardCell")
    self.view.addSubview(self.collectionView)
    self.collectionView.snp.makeConstraints{ make in
      make.edges.equalToSuperview()
    }
  }
}


extension PostViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return PostCardCell.size(width: collectionView.width, post: self.post, isMessageTrimmed: false)
  }
}

extension PostViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCardCell",
                                                  for: indexPath) as! PostCardCell
    cell.configure(post: self.post, isMessageTrimmed: false)
    return cell
  }
}
