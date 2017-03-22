//
//  FeedViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 22/02/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController {

  fileprivate struct Metric {
    static let tileCellSpacing = CGFloat(3)
  }
  
  // MARK: Properties
  
  var posts: [Post] = []
  ///더보기 url이 있는지 없는지 저장하기 위한 변수
  var nextURLString: String?
  var isLoading: Bool = false //로딩중일 떄는 로딩 안하게 하기 위한 변수
  var viewMode: FeedViewMode = .card {
    didSet {  //⭐️⭐️⭐️⭐️⭐️
      switch self.viewMode {
      case .card:
        self.navigationItem.leftBarButtonItem = self.tileButtonItem
      case .tile:
        self.navigationItem.leftBarButtonItem = self.cardButtonItem
      }
      self.collectionView.reloadData()
    }
  }
  
  
  // MARK: UI
  
  fileprivate let tileButtonItem = UIBarButtonItem(image: UIImage(named: "icon-tile"),
                                                   style: .plain,
                                                   target: nil,
                                                   action: nil)
  fileprivate let cardButtonItem = UIBarButtonItem(image: UIImage(named: "icon-card"),
                                                   style: .plain,
                                                   target: nil,
                                                   action: nil)
  
  let refreshControl = UIRefreshControl()
  //collectionView object생성시에는 반드시 이 2개의 params를 가져야 함
  //UICollectionViewFlowLayout() : 가장 기본적인 레이아웃만 제공하는 녀석
  //collectionViewLayout에 커스텀 하여 추가할 수도 있다.
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //⭐️⭐️⭐️이렇게 하면 해당 view의 navigationController의 tintColor만 변경됨 -> Appdelegate에서 변경하면 전체가 변경!!!!
    //self.navigationController?.navigationBar.tintColor = .black
    
    self.navigationItem.leftBarButtonItem = self.tileButtonItem
    self.tileButtonItem.target = self
    self.tileButtonItem.action = #selector(tileButtonItemDidTap)
    self.cardButtonItem.target = self
    self.cardButtonItem.action = #selector(cardButtonItemDidTap)
    
    //UIControlEvents : enum. 어떤 컨트롤에서 발생할 수 있는 이벤트들 정의.
    self.refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: .valueChanged)
    self.collectionView.backgroundColor = .white
    self.collectionView.alwaysBounceVertical = true //⭐️⭐️collectionView의 contentView가 scrollView보다 작으면 스크롤리 안되는데 이렇게 하면 항상 됨
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
                                            //class.self : 그 클래스 자체에 대한 참조
    self.collectionView.register(PostCardCell.self, forCellWithReuseIdentifier: "postCell")
    //postCell로 꺼내온 cell은 PostCardCell클래스이다. 라는 개념
    self.collectionView.register(PostTileCell.self, forCellWithReuseIdentifier: "tileCell")
    self.collectionView.register(CollectionActivityIndicatorView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "activityIndicatorView")

    self.view.addSubview(self.collectionView) //storyboard에서 드래그앤드롭 한것과 같음
    self.collectionView.addSubview(refreshControl)  //refreshControl은 collectionView에 addSubview
    
    //self.collectionView.frame = self.view.bounds  //collectionView의 초기 frame은 0,0이므로 이렇게 지정해줌
    //autolayout으로 collectionView frame
    self.collectionView.snp.makeConstraints{ make in
      /*
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
       */
      //make.left.right.top.bottom.equalToSuperview()
      make.edges.equalToSuperview()
    }
    
    self.refreshControlDidChangeValue()
    
    //⭐️addObserver는 자동 해지가 안되므로 꼭 해지해야함!!!! - 이 noti가 수신이 필요 없을 때!! 이 vc가 없을 때 -> deinit
    NotificationCenter.default.addObserver(self, selector: #selector(postDidLike), name: .postDidLike, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(postDidUnlike), name: .postDidUnlike, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(postDidCreate), name: .postDidCreate, object: nil)

  }
  
  
  // MARK: - Initializing
  
  //⭐️ tabBar item을 부여하기 위해!!!!
  init() {
    super.init(nibName: nil, bundle: nil) //⭐️ viewcontroller의 생성자는 기본적으로 nibName과 bundle을 받지만 우리는 코드로 만드므로 nil
    //self.tabBarItem.title = "Feed"    // ⭐️ 이렇게 탭바에 이미지 없이 title만 하는 경우는 나타나지 않음. tabbar image = 50px(@2x), 75px(@3x)
    //self.title = "Feed"   // ⭐️ 이렇게 하면 view의 title과 tabbar의 title에 다 들어감.(따로 지정해주지 않는 경우)
    self.tabBarItem.title = "Feed"
    self.tabBarItem.image = #imageLiteral(resourceName: "tab-feed")
    self.tabBarItem.selectedImage = #imageLiteral(resourceName: "tab-feed-selected")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self) // ⭐️ self에 있는 observer들 전부 제거
    //NotificationCenter.default.removeObserver(observer: Any, name: NSNotification.Name?, object: Any?) : 특정 observer만 지울 경우
  }
  
  fileprivate dynamic func tileButtonItemDidTap(){
    self.viewMode = .tile
    /*⭐️⭐️⭐️⭐️⭐️
      원래는 하단에 leftbarbutton 바꿔주고, reload도 해야하는데 이걸 didSet으로 한방에!!
     */
  }
  
  fileprivate dynamic func cardButtonItemDidTap(){
    self.viewMode = .card
  }
  
  fileprivate dynamic func refreshControlDidChangeValue(){  // ⭐️⭐️⭐️⭐️ 여기에 fileprivate만 쓰면 에러. selector에서 쓰려면 private안됨. but dynamic과 함께 사용하면 됨
    //self.loadFeed(isMore: false)
    self.loadFeed(paging: .refresh)
  }
  
  func loadFeed(paging: Paging) {
    guard !self.isLoading else { return }
    self.isLoading = true
    
    FeedService.feed(paging: paging){ response in
      self.isLoading = false
      self.refreshControl.endRefreshing()
      
      switch response.result {
      case .success(let feed):  //이때 넘어오는 value는 Feed type으로 넘어옴
        switch paging {
        case .refresh:
          self.posts = feed.posts
        case .next:
          self.posts.append(contentsOf: feed.posts)
        }
        self.nextURLString = feed.nextURLString
        self.collectionView.reloadData()
        
        //⭐️⭐️⭐️content의 수가 적어서 collectionView가 더보기 안될때 이거 호출 하면 더보기 할 수 있음
        self.scrollViewDidScroll(self.collectionView)
        
      case .failure(let error):
        print("피드 요청 실패 : \(error)")
      }
    }
  }
  /*
  func loadFeed(isMore: Bool){
    //중복 로딩 방지(false일때만 통과)
    guard !self.isLoading else { return }
    let urlString: String
    if !isMore {
      //Refresh
      urlString = "https://api.graygram.com/feed?limit=5"
    }else if let nextURLString = self.nextURLString{
      //더보기
      urlString = nextURLString
    }else{
      return
    }
    
    self.isLoading = true
    Alamofire.request(urlString)
      .responseJSON{ response in
        self.isLoading = false
        self.refreshControl.endRefreshing()
        switch response.result {
        case .success(let value):
          //value는 Any
          guard let json = value as? [String: Any] else { break }
          if let data = json["data"] as? [[String: Any]] {
            //Mappable protocol을 구현해서 가능한 init.
            //self.posts = [Post].init(JSONArray: data) ?? [] //post라는 객체의 배열임
            let newPosts = [Post].init(JSONArray: data) ?? []
            if !isMore {
              self.posts = newPosts
            }else{
              self.posts.append(contentsOf: newPosts)
            }
            self.collectionView.reloadData()
          }
          //nextURL을 꺼내오는 코드
          if let paging = json["paging"] as? [String: Any] {
            self.nextURLString = paging["next"] as? String
          }else{
            self.nextURLString = nil
          }
          
        case .failure(let error):
          print("요청 실패 : \(error)")
        }
    }
  }
  */
  
  // MARK: - Notifications
  
  func postDidLike(notification: Notification){
    guard let postID = notification.userInfo?["postID"] as? Int else { return }
//    for post in self.posts {  // ⭐️ 여기의 post는 let이므로 값 변경 불가.
    for (i, post) in self.posts.enumerated() {  // ⭐️⭐️⭐️ enumerated 사용하면 i, post 이렇게 사용 가능(인덱스를 손쉽게 가져다 쓸 수 있따!!!!!!!)
      if post.id == postID {
        var newPost = post  // ⭐️⭐️
        newPost.isLiked = true
        newPost.likeCount? += 1 //implicitly unwrapped optional 이므로 ? 해야함
        self.posts[i] = newPost
        self.collectionView.reloadData()  //UI update
        break
      }
    }
  }
  
  func postDidUnlike(notification: Notification){
    guard let postID = notification.userInfo?["postID"] as? Int else { return }
    for (i, post) in self.posts.enumerated() {
      if post.id == postID {
        var newPost = post
        newPost.isLiked = false
        newPost.likeCount? -= 1
        self.posts[i] = newPost
        self.collectionView.reloadData()
        break
      }
    }
  }
  
  func postDidCreate(notification: Notification){
    guard let post = notification.userInfo?["post"] as? Post else { return }
    self.posts.insert(post, at: 0)
    self.collectionView.reloadData()
  }
  
}

extension FeedViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.posts.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let post = self.posts[indexPath.item]
    switch self.viewMode {
    case .card:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCardCell
      // ⭐️ collectionView에서는 row 대신 item 사용! row는 줄개념. collectionView는 행, 열 다 가능하므로 row 대신 item으로 쓴다
      cell.configure(post: post, isMessageTrimmed: true)
      return cell
    case .tile:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! PostTileCell
      cell.configure(post: post)
      return cell
    }
  }
  
  // ⭐️ 여기에 activityIndicator 구현할 것. 앱 실행시키면 footer가 먼저 실행된 상태(최상단 위치)에서 cell들이 그려지는것을 알 수 있음
  /* 그래서 여기에 더보기 구현하면 초기 아무것도 없을 시에 loading도 구현할 수 있음
  -> collectionView 가장 하단에 activityIndicator를 붙인다.
  -> UICollectionReusableView에 넣으면 됨!! 이녀석은 tableView의 footer, header처럼 하나만 갖는게 아니라(전체 tableView에 하나씩) 여러개 아무곳에서나 가질 수 있음(섹션별로 하나씩)
 */
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                               withReuseIdentifier: "activityIndicatorView",
                                                               for: indexPath)
    return view
  }
}


extension FeedViewController: UICollectionViewDelegateFlowLayout {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //scrollView.contentOffset : 스크롤이 어디있는지 위치. contentOffSet은 보여지는 화면의 맨 위가 기준. contentSize는 보여지는 화면 맨 밑이 기준. 얼마만큼 스크롤 되는가
    //⭐️ contentOffset은 collectionView의 맨 위가 0. 아래로 내려갈 수록 증가
    //⭐️ 따라서 contentOffSet + collectioinView Height = contentSize
    //⭐️ scrollView.contentSize : 스크롤 최대 높이
    if scrollView.contentOffset.y + scrollView.height >= scrollView.contentSize.height - 200 && scrollView.contentSize.height > 0 {
      //loadFeed(isMore: true)
      if let nextURLString = self.nextURLString {
        self.loadFeed(paging: .next(nextURLString))
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let post = self.posts[indexPath.item]
    switch self.viewMode {
    case .card:
      return PostCardCell.size(width: collectionView.width, post: post, isMessageTrimmed: true) //PostCardCell에서 size 계산하는 함수 호출
    case .tile:
      let cellWidth = round((collectionView.width - Metric.tileCellSpacing * 2) / 3)  //⭐️소수점 없애지 않으면 화면이 흐리게 보이는 현상 발생할 수 있음
      return PostTileCell.size(width: cellWidth, post: post) //⭐️cell들 간의 간격 고려해야함!!! collectionView는 item간 간격을 기본으로 10px 갖고 있음
    }
  }
  
  //cell사이 세로 간격 - 첫번째 cell에는 적용이 안됨
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    switch self.viewMode {
    case .card:
      return 15
    case .tile:
      return Metric.tileCellSpacing
    }
  }
  
  //cell 사이 가로 간격
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    switch self.viewMode {
    case .card:
      return 0
    case .tile:
      return Metric.tileCellSpacing
    }
  }
  
  //각 섹션에 inset을 부여함 - 안쪽의 너비 조절 minimumLineSpacingForSectionAt이 첫번쨰 cell과 마지막Cell에 적용이 안되므로.
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    switch self.viewMode {
    case .card:
      return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    case .tile:
      return .zero
    }
    
  }
  
  //supplementaryElementView size
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if self.nextURLString == nil && !self.posts.isEmpty { //더 불러올것 없고 & 현재 데이터 있을 때
      return CGSize(width: collectionView.width, height: 0)
    }else{
      return CGSize(width: collectionView.width, height: 44)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let post = self.posts[indexPath.item]
    let postViewController = PostViewController(post: post)
    self.navigationController?.pushViewController(postViewController, animated: true)
  }
}
