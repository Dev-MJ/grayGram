//
//  FeedViewController
//  GrayGram
//
//  Created by Dev.MJ on 01/03/2017.
//  Copyright © 2017 HelloMJ. All rights reserved.
//

import UIKit
import Alamofire

class FeedViewController: UIViewController {

  // MARK: - Properties
  var posts: [Post] = []
  
  
  // MARK: - UI
  
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    
    self.collectionView.frame = self.view.frame
    self.collectionView.backgroundColor = .lightGray
    
    self.collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "PostCardCell")
    
    self.view.addSubview(self.collectionView)
    
    loadData(isMore: false)
  }
  
  func loadData(isMore: Bool){
    let urlString = "https://api.graygram.com/feed?limit=5"
    
    Alamofire.request(urlString)
      .responseJSON{ response in
        switch response.result {
        case .success(let value):
          guard let json = value as? [String: Any] else { return }
          let jsonArray = json["data"] as? [[String: Any]] ?? []
          let newPosts = [Post](JSONArray: jsonArray) ?? []
          if !isMore {
            self.posts = newPosts
          }else{
            self.posts.append(contentsOf: newPosts)
          }

          self.collectionView.reloadData()
        case .failure(let error):
          print(error)
        }
    }
  }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension FeedViewController: UICollectionViewDelegateFlowLayout {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height * 0.8 {
      print("더보기")
    }
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return PostCardCell.size(width: collectionView.width)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return .zero
  }
}


// MARK: - UICollectionViewDataSource

extension FeedViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.posts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCardCell", for: indexPath) as! PostCardCell
    cell.congifure(post: self.posts[indexPath.item])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 15
  }
  
}

