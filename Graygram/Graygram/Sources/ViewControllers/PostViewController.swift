//
//  PostViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 22/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

import URLNavigator

final class PostViewController: UIViewController {
  
  fileprivate let postID: Int //postID 추가. url scheme을 통해 오는 postID로 이 ViewController를 띄울 수있게 하기 위해서.
  fileprivate var post: Post?
  fileprivate let collectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: UICollectionViewFlowLayout()) //⭐️⭐️UICollectionViewFlowLayout이어야 하단에 delegate도 호출이 됨!!!
  fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  //⭐️⭐️postID 추가. url scheme(grgm://post/3)을 통해 오는 postID로 이 ViewController를 띄울 수있게 하기 위해서. url scheme에는 post객체를 전달할 수 없으니까!
  init(postID: Int, post: Post?) {
    self.postID = postID
    self.post = post
    super.init(nibName: nil, bundle: nil)
    
    //post를 갱신할것! by postID
    self.fetchPost()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.backgroundColor = .white
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "postCardCell")
    self.view.addSubview(self.collectionView)
    self.view.addSubview(self.activityIndicatorView)
    self.collectionView.snp.makeConstraints{ make in
      make.edges.equalToSuperview()
    }
    self.activityIndicatorView.snp.makeConstraints{ make in
      make.center.equalToSuperview()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(postDidLike), name: .postDidLike, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(postDidUnlike), name: .postDidUnlike, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //⭐️⭐️⭐️push로 넘어왔는제, present로 넘어왔는지 확인 하는 방법!!!⭐️⭐️⭐️ - viewdidload에서는 navigationController가 nil일 확률이 높음!!
    if self.navigationController?.viewControllers.count ?? 0 > 1 {  //pushed
      //ViewControllers : navigationController에 담겨있는 vc들이 늘어날때마다 하나씩 늘어남. 최초 1.
      self.navigationItem.leftBarButtonItem = nil //⭐️⭐️⭐️system 기본값을 사용하도록
    } else if self.presentingViewController != nil {  //presented
      //The view controller that presented this view controller.
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                              target: self,
                                                              action: #selector(cancelButtonItemDidTap))
    }
    
  }
  
  func cancelButtonItemDidTap(){
    self.dismiss(animated: true, completion: nil)
  }
  
  func postDidLike(notification: Notification){
    guard var post = self.post else { return }
    guard let postID = notification.userInfo?["postID"] as? Int else { return }
    guard post.id == postID else { return }
    
    post.isLiked = true
    post.likeCount? += 1
    self.post = post
    self.collectionView.reloadData()
  }
  
  func postDidUnlike(notification: Notification){
    guard var post = self.post else { return }
    guard let postID = notification.userInfo?["postID"] as? Int else { return }
    guard post.id == postID else { return }
    
    post.isLiked = false
    post.likeCount? -= 1
    self.post = post
    self.collectionView.reloadData()
  }
  
  func fetchPost(){
    //post가 있는경우는 바로 그 post를 보여주고, post가 없는 경우는 networking으로 불러와야 하므로 activityIndicator 보여줄것!
    //activityIndicatorView는 기본으로 startAnimating하면 보여지고, stop 하면 안보임
    self.activityIndicatorView.startAnimating()
    //⭐️⭐️네트워크 시 주의점 !!⭐️⭐️ 클로져에 있는 self는 weaK 으로 처리!!!
    PostService.post(id: self.postID){ [weak self] response in
      guard let `self` = self else { return }
      self.activityIndicatorView.stopAnimating()
      switch response.result {
      case .success(let post):
        self.post = post
        self.collectionView.reloadData()
      case .failure(let error):
        print(error)
      }
    }
  }
}


// MARK: - URLNavigator

extension PostViewController: URLNavigable {
  convenience init?(url: URLConvertible,   //grgm://post/3
       values: [String: Any], //["id":"3"]
       userInfo: [AnyHashable: Any]?) {
    
    guard let postID = values["id"] as? Int else { return nil }
    self.init(postID: postID, post: nil)  //self의 생성자 다시 호출
    
  }
}

extension PostViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
  }
  
  //이게 호출이 안되는 경우 : collectionView가 없거나, 크기가 0이거나
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return PostCardCell.size(width: collectionView.width, post: self.post!, isMessageTrimmed: false)
  }
}

extension PostViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if self.post == nil {
      return 0
    }
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCardCell",
                                                  for: indexPath) as! PostCardCell
    cell.configure(post: self.post!, isMessageTrimmed: false)
    return cell
  }
}
