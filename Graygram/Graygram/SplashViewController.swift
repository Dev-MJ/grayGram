//
//  SplashViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 06/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

import Alamofire

final class SplashViewController: UIViewController {
  
  let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    self.activityIndicator.startAnimating()
//    self.activityIndicator.centerX = self.view.width / 2
//    self.activityIndicator.centerY = self.view.height / 2
    self.view.addSubview(activityIndicator)
    self.activityIndicator.snp.makeConstraints{ make in
      make.center.equalToSuperview()  //activityIndicator는 자체 width, height 갖고 있으므로 center만 해줘도 됨
    }
    
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    //application이 초기화 되고 view가 그려진 직후
    
    checkLoginSession()
    /*
     Q. 왜 viewDidLoad에 안하고 여기에 할까?
     A. viewDidLoad가 Appdelegate에 있는 let viewController = SplashViewController()
                                      window.rootViewController = viewController
                                      에서 window.rootViewController = viewController가 선언되기 전에 실행되어 버릴 수 있기 때문!!
     */
    
    
  }
  
  func checkLoginSession(){
    let urlString = "https://api.graygram.com/me" // ⭐️⭐️⭐️ alamofire에서는 계속 세션 저장(쿠키에 저장)하므로 이렇게 요청해도 세션 확인 가능함.
    request(urlString)
      .validate(statusCode: 200..<400)
      .responseJSON{ response in
        switch response.result {
        case .success:
          if let statusCode = response.response?.statusCode, statusCode == 200 {
            AppDelegate.instance?.presentMainScreen() // ⭐️ 여기서 noti를 쏴서 appdelegate에서 rootVC를 변경하는 방법도 있다! -> 이 rootVC 전환하는 방식의 단점은, 화면 전환효과를 주기 어려움
          }else{
            AppDelegate.instance?.presentLoginScreen()
          }
        case .failure:
          AppDelegate.instance?.presentLoginScreen()
        }
        
        
    }
  }
  
  
}
