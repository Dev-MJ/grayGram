//
//  CropViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 13/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class CropViewController: UIViewController {
  
  //crop이 완료된 이미지를 클로져로 전달. 초기값이 없기 때문에 ()로 감싸서 Optional로 정의.
  var didFinishCropping: ((UIImage) -> Void)?
  //var didFinishCropping: ((image: UIImage) -> Void)?  3.0부터는 안됨. (_ image: UIImage)로는 가능
  
  fileprivate let scrollView = UIScrollView() //zoom, scroll 하기 위함
  fileprivate let imageView = UIImageView()
  
  
  /// 이미지가 크롭 될 정사각형 영역을 가이드해주는 뷰
  fileprivate let cropAreaView = UIView()
  fileprivate let cropAreaTopCoverView = UIView()
  fileprivate let cropAreaBottomCoverView = UIView()
  
  //전 VC로부터 이미지 받는 방법!
  //1. 생성자(init)로 이미지를 받기
  //2. 속성으로 전달 받기
  init(image: UIImage) {
    super.init(nibName: nil, bundle: nil) //UIViewController의 기본 생성자이므로 꼭 호출시켜줘야 함
    self.imageView.image = image
    
    //⭐️⭐️⭐️ UIViewController에 정의되어있음. self.view의 0번째 scrollView에만 적용됨(자동으로 scrollView의 inset을 잡아주지 않는다)
    //iOS7부터 navi가 투명이되면서, scrollView의 위치를 navi만큼 내려주는 코드가 추가됨. 이를 해제하는 코드
    self.automaticallyAdjustsScrollViewInsets = false
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    
    //⭐️이렇게 leftBarButtom을 넣으면 swipe back이 없어짐.
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(cancelButtonDidTap))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                             target: self,
                                                             action: #selector(doneButtonDidTap))
    
    self.scrollView.delegate = self
    self.scrollView.showsVerticalScrollIndicator = false
    self.scrollView.showsHorizontalScrollIndicator = false
    self.scrollView.maximumZoomScale = 3 //최대 확대 배율
    
    //cropAreaView의 테두리 작성,  CALayer : Core Animation Layer
    self.cropAreaView.layer.borderColor = UIColor.black.cgColor
    //self.cropAreaView.layer.borderWidth = 1   //⭐️⭐️ 1px -> 6에서는 2px, plus에서는 3px로 그려짐
    self.cropAreaView.layer.borderWidth = 1 / UIScreen.main.scale // ⭐️⭐️ plus: 3, 6: 2 임. -> 각 기종마다 1px로 그려짐
    
    self.cropAreaTopCoverView.alpha = 0.7
    self.cropAreaBottomCoverView.backgroundColor = .white
    self.cropAreaBottomCoverView.alpha = 0.7
    
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.imageView)
    self.view.addSubview(self.cropAreaView) // ⭐️ 마지막에 해야 cropAreaView가 위에 보임
    self.view.addSubview(self.cropAreaTopCoverView)
    self.view.addSubview(self.cropAreaBottomCoverView)  // ⭐️ 얘네들이 scrollView 위에 있으므로, 터치이벤트를 먹어버림.
    
    //그래서 얘네는 터치이벤트를 무시하게끔 해버림
    self.cropAreaView.isUserInteractionEnabled = false
    self.cropAreaTopCoverView.isUserInteractionEnabled = false
    self.cropAreaBottomCoverView.isUserInteractionEnabled = false
    
    self.scrollView.snp.makeConstraints{ make in
      //make.top.left.right.bottom.equalToSuperview()
      make.edges.equalToSuperview()
    }
    
    self.cropAreaView.snp.makeConstraints{ make in
      make.width.equalToSuperview()
      make.height.equalTo(self.cropAreaView.snp.width)
      make.centerY.equalToSuperview()
    }
    
    self.cropAreaTopCoverView.snp.makeConstraints{ make in
      make.width.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalTo(self.cropAreaView.snp.top)
    }
    
    self.cropAreaBottomCoverView.snp.makeConstraints{ make in
      make.width.equalToSuperview()
      make.top.equalTo(self.cropAreaView.snp.bottom)
      make.bottom.equalToSuperview()
    }
    
  }
  
  //imageView는 오토레이아웃으로 하는건 비추.(scrollView안에 들어가므로, zoom할때마다, scroll할때마다 overhead!!
  //imageView frame 설정
  /*⭐️⭐️⭐️
   UIViewController는 View를 가지는데, 이 View의 `layoutSubviews()` 메서드가 호출된 후에 UIViewController의 `viewDidLayoutSubviews` 메서드가 호출됩니다. 즉, 뷰가 레이아웃 작업을 할 때마다 호출되는 메서드
   */
  /*⭐️⭐️⭐️
  오토 레이아웃 constraints는 한 번만 작성되어야 합니다. `viewDidLayoutSubviews`와 `viewDidAppear`는 여러 번 호출되기 때문에 어울리는 장소가 아닙니다.
  사실 `viewDidLoad`도 이론상으로는 여러번 호출될 수 있기 때문에 오토 레이아웃 코드를 다른 방식으로 작성하는 것을 권장
   */
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    self.initializeImageViewFrameIfNeeded()
    
    //contentView의 크기 조정(위에서 얼만큼, 아래서 얼만큼 띄움)
    self.scrollView.contentInset.top = self.scrollView.height / 2 - self.cropAreaView.height / 2
    self.scrollView.contentInset.bottom = self.scrollView.contentInset.top
    self.scrollView.contentSize = self.imageView.size       //가로가 긴 이미지면 contentView는 가로로, 세로가 긴 이미지면 세로로 길게 됨
    
    //contentView를 가운데 오게끔 하기 위함.???
    self.scrollView.contentOffset.x = self.scrollView.contentSize.width / 2 - self.scrollView.width / 2
    self.scrollView.contentOffset.y = self.scrollView.contentSize.height / 2 - self.scrollView.height / 2
    
  }
  
  func initializeImageViewFrameIfNeeded(){  //- IfNeeded : 바로 실행이 아니라, 어떠한 조건이 수행될 때만 실행되는 naming convention
    /*
    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()  //setNeedsLayout이 수행되어야 수행됨
     */
    
    //imageView의 초기사이즈 설정. ⭐️맨 처음 선언시에는 imageView의 사이즈는 zero이므로!
    guard self.imageView.size == .zero else { return }
    
//    self.imageView.size = self.cropAreaView.size  //size만 조정
//    self.imageView.centerY = self.scrollView.height / 2 //y 위치 조정. ⭐️⭐️⭐️ navi만큼 scrollView를 내려주기 때문에, 중앙정렬하면 그만큼 내려와서 정렬이되어버림.
    
    
    //scrollView는 contentSize가 더 클 때 스크롤이 됨. default는 0임.
    guard let image = self.imageView.image else { return }
    
    //image의 크기별로 contentsize 처리
    if image.size.width > image.size.height {
      //image가 가로로 긴 경우 - landscape 이미지 : 가로를 cropAreaView에 맞춘다
      //비례식 이용.
      self.imageView.height = self.cropAreaView.height
      self.imageView.width = self.imageView.height * image.size.width / image.size.height  //비례식
      
    }else if image.size.width < image.size.height {
      //image가 세로로 긴 경우 - portrait 이미지 : 세로를 cropAreaView에 맞춘다
      //비례식 이용.
      self.imageView.width = self.cropAreaView.width
      self.imageView.height = self.imageView.width * image.size.height / image.size.width
      
    }else {
      //square 이미지
      self.imageView.size = self.cropAreaView.size
    }
    
//    self.imageView.centerY = self.scrollView.height / 2
  }
  
  
  func cancelButtonDidTap(){
    _ = self.navigationController?.popViewController(animated: true)  // push <-> pop
  }
  
  func doneButtonDidTap(){
    //1. 이미지를 영역에 맞게 crop
    //2. 이미지가 crop됐다고 알려줌
    guard let image = self.imageView.image else { return }
    //UIView.convert(CGRect, from:)
    //UIView.convert(CGRect, to:)
    
    //⭐️⭐️⭐️
    var rect = self.scrollView.convert(self.cropAreaView.frame, from: self.cropAreaView.superview)
    //self.view가 본 cropAreaView의 frame을 scrollView가 본 cropAreaView의 frame으로 바꾼다 -> scrollView의 imageView의 frame을 cropAreaView에서도 같이 계산할 수 있음
    //imageView의 기준좌표계와 cropAreaView의 기준좌표계 통일
    //기준좌표계 : self.scrollView / self.cropAreaView.superview가 기준인 self.cropAreaView.frame을 self.scrollView의 기준좌표계로 변환하겠다.
    
    //원래 이미지크기와 이미지뷰크기의 비율만큼 crop될 영역도 커지거나 줄어져야 하므로 그  곱해줌. 스크롤시에도 x, y 이동하는 정도가 비율과 같으므로
    rect.origin.x *= image.size.width / self.imageView.width
    rect.origin.y *= image.size.height / self.imageView.height
    rect.size.width *= image.size.width / self.imageView.width
    rect.size.height *= image.size.height / self.imageView.height
    
    if let croppedCGImage = image.cgImage?.cropping(to: rect) {
      let croppedImage = UIImage(cgImage: croppedCGImage)
      print(croppedImage)
      self.didFinishCropping?(croppedImage) //croppedImage 전달!
    }
  }
  
  @discardableResult  // ⭐️⭐️이 함수가 반환하는 결과를 사용하지 않아도 compile warning 안뜬다!!!
  func foo() -> Int {
    return 10
  }
}


extension CropViewController: UIScrollViewDelegate {
 
  //⭐️zoom을 할 떄 어떤 view를 zoom 시킬지 결정
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
}
