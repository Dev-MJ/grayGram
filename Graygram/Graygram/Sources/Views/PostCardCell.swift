//
//  PostCardCell.swift
//  Graygram
//
//  Created by Dev.MJ on 22/02/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

//더이상 상속이 발생하지 않을 클래스
final class PostCardCell: UICollectionViewCell {
  
  // MARK: Constants
  
  struct Metric {
    static let userPhotoViewTop = CGFloat(0)
    static let userPhotoViewLeft = CGFloat(10)
    static let userPhotoViewWidth = CGFloat(30)
    static let userPhotoViewHeight = CGFloat(30)
    
    static let usernameLabelLeft = CGFloat(10)
    static let usernameLabelRight = CGFloat(10)
    
    static let photoViewTop = CGFloat(10)
    
    static let likeButtonTop = CGFloat(10)
    static let likeButtonLeft = CGFloat(10)
    static let likeButtonWidth = CGFloat(20)
    static let likeButtonHeight = CGFloat(20)
    
    static let messageLabelTop = CGFloat(10)
    static let messageLabelLeft = CGFloat(10)
    static let messageLabelRight = CGFloat(10)
    
    static let likeCountLabelLeft = CGFloat(10)
    static let likeCountLabelRight = CGFloat(10)
  }
  
  // MARK: - Font
  
  struct Font {
    static let usernameLabel = UIFont.boldSystemFont(ofSize: 13)
    static let likeCountLabel = UIFont.boldSystemFont(ofSize: 12)
    static let memessageLabel = UIFont.systemFont(ofSize: 13)
  }
  
  
  // MARK: - Properties
  
  fileprivate var post: Post?
  
  
  // MARK: - UI
  
  fileprivate let userPhotoView = UIImageView()
  fileprivate let usernameLabel = UILabel()
  fileprivate let photoView = UIImageView()
  fileprivate let likeButton = UIButton()
  fileprivate let likeCountLabel = UILabel()
  fileprivate let messageLabel = UILabel()  //외부에서 접근할 필요 없음. private: 선언된 영역내에서만 접근이 가능. 
                                            //extension이나 상속받은 곳에서 사용 x . 
                                            //fileprivate : 같은 파일일 경우 접근할 수 있는 접근한정자
  
  
  //https://swifter.kr/2016/10/09/새로운-접근한정자-open-fileprivate에-대해/
  
  // ⭐️ 코드로 작성시, UICollectionViewCell에서 무조건 구현해야 하는
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    //CALayer : UIView는 CALayer를 한 번 wrapping해서 만든것.
    self.userPhotoView.layer.cornerRadius = Metric.userPhotoViewWidth / 2 // ⭐️ 이것도 퍼포먼스에 굉장히 안좋음
    self.userPhotoView.clipsToBounds = true // ⭐️ 이 녀석 해야 원형으로 됨
    //1. 가운데만 원형 투명이미지를 사각형 이미지 위에 덧씌운다
    //2. 그냥 사각형으로 한다.
    
    self.usernameLabel.font = Font.usernameLabel
    self.photoView.backgroundColor = .lightGray
    
    self.likeButton.setBackgroundImage(#imageLiteral(resourceName: "icon-like"), for: .normal)  // 40px(@2x), 60px(@3x)
    self.likeButton.setBackgroundImage(#imageLiteral(resourceName: "icon-like-selected"), for: .selected)
    self.likeButton.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
    
    self.likeCountLabel.font = Font.likeCountLabel
    
    self.messageLabel.font = Font.memessageLabel
    self.messageLabel.numberOfLines = 3
    
    self.contentView.addSubview(self.userPhotoView)
    self.contentView.addSubview(self.usernameLabel)
    self.contentView.addSubview(self.photoView)
    self.contentView.addSubview(self.likeButton)
    self.contentView.addSubview(self.likeCountLabel)
    self.contentView.addSubview(self.messageLabel) // ⭐️ tableViewCell이나 collectioniViewCell에서는 contentView에 addSubview해줘야함
    
  }
  
  // ⭐️ storyboard 사용시 사용하게 되는 생성자
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - configure
  
  /// - parameter post: `Post` 인스턴스
  /// - parameter isMessageTrimmed: 메세지 라벨 높이를 제한할 것인지를 나타냅니다.
  func configure(post: Post, isMessageTrimmed: Bool){
    self.backgroundColor = .white
    /*  UIImageView extension으로 축약!!!!
    let url = URL(string: "https://www.graygram.com/photos/\(post.photoID!)/600x600")  //https여서 security 설정 안해도 됨
    self.photoView.kf.setImage(with: url)
     */
    self.post = post
    self.userPhotoView.setImage(with: post.userPhotoID)
    self.usernameLabel.text = post.username
    self.photoView.setImage(with: post.photoID!)
    self.likeButton.isSelected = post.isLiked
    self.likeCountLabel.text = self.likeCountLabelText(with: post.likeCount)
//    if post.likeCount == 0 {
//      self.likeCountLabel.text = "가장 먼저 좋아요를 눌러보세요"
//    }else{
//      self.likeCountLabel.text = "\(post.likeCount ?? 0)명이 좋아합니다" //optional 붙은 이유 : implicitly unwrapp optional임. 즉 옵셔널 처리가 됨. swift2까지는 자동으로 되었음.
//    }
    
    self.messageLabel.text = post.message
    self.messageLabel.numberOfLines = isMessageTrimmed ? 3 : 0
    self.setNeedsLayout()
  }
  
  
  // MARK: - size
  
  //자기 자신의 너비에 따라 cell size 계산하는 함수 설정
  class func size(width: CGFloat, post: Post, isMessageTrimmed: Bool) -> CGSize {
    var height: CGFloat = 0
    
    /* height 계산 */
    
    //3. userphotoview의 높이 추가
    height += Metric.userPhotoViewTop
    height += Metric.userPhotoViewHeight
//    height += Metric.photoViewTop
    
    // 1. photoView의 높이 계산
    height += Metric.photoViewTop
    height += width
    
    height += Metric.likeButtonTop
    height += Metric.likeButtonHeight
    
    //2. messageLabel 높이 계산
    if let message = post.message, !message.isEmpty {
      height += Metric.messageLabelTop
      
      height += message.height(width: width - Metric.messageLabelLeft - Metric.messageLabelRight, font: Font.memessageLabel, numberOfLines: isMessageTrimmed ? 3 : 0)
      
      /*
      //string이 랜더링 될 최대 크기
      let messageLabelMaxSize = CGSize(width: width - Metric.messageLabelLeft - Metric.messageLabelRight, height: Font.memessageLabel.lineHeight * 3)
      // ⭐️⭐️⭐️ boundingRect는 NSString에서만 구현 가능하므로 casting후에 as NSString 지우면 가능하다....
      //문자열을 그리는데 필요한 공간 계산!
      //with : 최대 사이즈
      //options : 그냥 외우자....
      //attributes : 높이 계산하려면 어떤 폰트인지 알아야 하므로 그 폰트를 보내줌
      let boundingRect = message.boundingRect(with: messageLabelMaxSize,
                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                           attributes: [NSFontAttributeName: Font.memessageLabel],
                           context: nil)
 
      height += ceil(boundingRect.height) //무리수이므로, ceil(소수점 올림 사용) - boundingRect계산하면 높이가 무리수가 나오므로 픽셀이 조금씩 밀릴 수 있음
       */
    }
    
    return CGSize(width: width, height: height)
  }
  
  
  //이곳에서 view들의 layout을 정의해줘야 함
  //⭐️ cell의 frame이 바뀌거나, 레이아웃을 해라! 라는 명시적인 메시지(setNeedsLayout(), layoutIfNeeded())가 전달 될때 실행됨
  override func layoutSubviews() {
    super.layoutSubviews()
    
    /*
    self.photoView.frame.size.width = self.contentView.frame.width
    self.photoView.frame.size.height = self.photoView.frame.width
    
    self.messageLabel.frame.origin.x = 10 //좌측 여백을 주기 위해 10 띄우고
    self.messageLabel.frame.origin.y = self.photoView.frame.height + 10
    self.messageLabel.frame.size.width = self.contentView.frame.width - 20  //여백 주기 위해 너비 조절 한다
     */
    
    
    //ManualLayout 사용하여 코드 축약
    
    //userPhotoView
    self.userPhotoView.top = Metric.userPhotoViewTop
    self.userPhotoView.left = Metric.userPhotoViewLeft
    self.userPhotoView.width = Metric.userPhotoViewWidth
    self.userPhotoView.height = Metric.userPhotoViewHeight
    
    //usernameLabel
    self.usernameLabel.left = self.userPhotoView.right + Metric.usernameLabelLeft
    self.usernameLabel.sizeToFit()  //name이 길 경우, 엄청 늘어나 버림
//    self.usernameLabel.width = self.contentView.width - self.usernameLabel.left - Metric.usernameLabelRight  //그래서 다시 최대 너비를 지정 -> 이름이 짧아도 width가 최대로 되어버림
    self.usernameLabel.width = min(self.usernameLabel.width, self.contentView.width - self.usernameLabel.left - Metric.usernameLabelRight)  //둘 중 최소값을 할당.(name에 맞게끔 width가 조절됨
    self.usernameLabel.centerY = self.userPhotoView.centerY
    //sizetoFit을 한 뒤에 해야 center가 맞는다. why?
    //centerY를 정할 당시 label의 frame은 0이다. 따라서 이 frame인 상태에서 center가 잡힘.
    //그리고 나서 sizeToFit을 하게 되면 그 상태로 오른쪽 아래로 늘어나기 때문에 다르게 layout이 잡힘
    
    
    //photoView
    self.photoView.width = self.contentView.width
    self.photoView.height = self.photoView.width
    self.photoView.top = self.userPhotoView.bottom + Metric.photoViewTop
    
    self.likeButton.top = self.photoView.bottom + Metric.likeButtonTop
    self.likeButton.left = Metric.likeButtonLeft
    self.likeButton.width = Metric.likeButtonWidth
    self.likeButton.height = Metric.likeButtonHeight
    
    self.likeCountLabel.sizeToFit() //먼저 기본 높이와 너비를 지정!!
    self.likeCountLabel.left = self.likeButton.right + Metric.likeCountLabelLeft
    //ㄴ> 여기까진 y좌표가 0인 상태.
    self.likeCountLabel.centerY = self.likeButton.centerY
    //self.likeCountLabel.width = self.contentView.width - self.likeCountLabel.left - Metric.likeCountLabelRight // 최대 너비 지정
    self.likeCountLabel.width = min(self.likeCountLabel.width, self.contentView.width - self.likeCountLabel.left - Metric.likeCountLabelRight)
    
    //left = .x와 동일
    self.messageLabel.left = Metric.messageLabelLeft
    //top = .y와 동일          //bottom = .y와 동일
    self.messageLabel.top = self.likeButton.bottom + Metric.messageLabelTop
    self.messageLabel.width = self.contentView.width - Metric.messageLabelLeft - Metric.messageLabelRight
    self.messageLabel.sizeToFit() //위에서 너비 지정 안하고 사용하면 numberofLines가 먹지 않음 => width가 있으면 width를 유지한 채 높이만 조정하게 됨
  }
  
  
  // MARK: - Action
  
  func likeButtonDidTap(){
    if !self.likeButton.isSelected {
      self.like()
    }else{
      self.unlike()
    }
  }
  
  func like(){
    /*
    //⭐️postID를 여기서 쓰기 위해 전역변수로 postID 저장변수 선언한다! -> post 하나로 퉁치게 변경
    //guard let postID = self.post?.id else { return }
    guard let post = self.post else { return }
    
    NotificationCenter.default.post(name: .postDidLike, object: self, userInfo: ["postID":post.id])
    
    /* Noti 사용해서 이 부분 제거 - view의 data가 아닌, controller의 data를 바꾼다!!
      ㄴ> post는 Struct이므로, 여기서 바꿔도 Controller의 post는 변경되지 않기 떄문에 cell 재사용으로 인해 cell.configure 실행되면 다시 view의 data는 리셋됨!!!!
    // ⭐️ 사용자에게 좀 더 빠르게 인식시키기 위해 요청 하기 전에 post 변경 코드를 작성한다!!!!!!!
    self.likeButton.isSelected = true
    //개수 변화시켜줘야 하므로 개수도 갖고 있어야 하는데 postID도 필요했었으니까 post 자체를 갖고 있게끔 하자!
    //self.likeCountLabel.text = "\(post.likeCount + 1)명이 좋아합니다"
    self.likeCountLabel.text = self.likeCountLabelText(with: post.likeCount + 1)
    */
    let urlString = "https://api.graygram.com/posts/\(post.id!)/likes"  //post:좋아요 요청, delete: 좋아요 취소
    request(urlString, method: .post)
      .responseJSON { response in
        switch response.result {
        case .success:
          print("좋아요 요청 성공")
        case .failure(let error):
          print(error)
          //좋아요가 실패한 경우, 취소한 noti를 보내주면 될것!
          NotificationCenter.default.post(name: .postDidUnlike, object: self, userInfo: ["postID":post.id])
          /*
          self.likeButton.isSelected = post.isLiked
          //self.likeCountLabel.text = "\(originalLikeCount!)명이 좋아합니다"
          self.likeCountLabel.text = self.likeCountLabelText(with: post.likeCount)
           */
        }
    }
 */

    guard let post = self.post else { return }
    NotificationCenter.default.post(name: .postDidLike, object: self, userInfo: ["postID":post.id])
    PostService.like(postID: post.id){ response in
      switch response.result {
      case .success:
        print("좋아요 요청 성공")
      case .failure(let error):
        NotificationCenter.default.post(name: .postDidUnlike, object: self, userInfo: ["postID":post.id])
         self.likeButton.isSelected = post.isLiked
         self.likeCountLabel.text = self.likeCountLabelText(with: post.likeCount)
 
      }
    }
  }
  
  func unlike(){
/*
    //postID를 여기서 쓰기 위해 전역변수로 postID 저장변수 선언한다! -> post 하나로 퉁치게 변경
    //guard let postID = self.post?.id else { return }
    guard let post = self.post else { return }
    NotificationCenter.default.post(name: .postDidUnlike, object: self, userInfo: ["postID":post.id])
    /*
    //사용자에게 좀 더 빠르게 인식시키기 위해 요청 하기 전에 post 변경 코드를 작성한다!!!!!!!
    self.likeButton.isSelected = false
    //개수 변화시켜줘야 하므로 개수도 갖고 있어야 하는데 postID도 필요했었으니까 post 자체를 갖고 있게끔 하자!
    //self.likeCountLabel.text = "\(post.likeCount + 1)명이 좋아합니다"
    self.likeCountLabel.text = self.likeCountLabelText(with: post.likeCount - 1)
    */
    let urlString = "https://api.graygram.com/posts/\(post.id!)/likes"  //post:좋아요 요청, delete: 좋아요 취소
    request(urlString, method: .delete)
      .responseJSON { response in
        switch response.result {
        case .success:
          print("좋아요 취소 요청 성공")
        case .failure(let error):
          print(error)
          NotificationCenter.default.post(name: .postDidLike, object: self, userInfo: ["postID":post.id])
          /*
          self.likeButton.isSelected = post.isLiked
          //self.likeCountLabel.text = "\(originalLikeCount!)명이 좋아합니다"
          self.likeCountLabel.text = self.likeCountLabelText(with: post.likeCount)
           */
        }
    }
 */

    guard let post = self.post else { return }
    NotificationCenter.default.post(name: .postDidUnlike, object: self, userInfo: ["postID":post.id])
    PostService.unlike(postID: post.id){ response in
      switch response.result {
      case .success:
        print("좋아요 취소 성공")
      case .failure(let error):
        NotificationCenter.default.post(name: .postDidLike, object: self, userInfo: ["postID":post.id])
      }
    }
  }
  
  //likeCountLabel의 text를 반환하는 함수 생성
  
  func likeCountLabelText(with likeCount: Int) -> String {
    if likeCount == 0 {
      return "가장 먼저 좋아요를 눌러보세요"
    }else{
      return "\(likeCount)명이 좋아합니다"
    }
  }
}
