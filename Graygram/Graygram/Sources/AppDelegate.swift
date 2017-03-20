//
//  AppDelegate.swift
//  Graygram
//
//  Created by Dev.MJ on 22/02/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

//extension으로 되어있는 라이브러리는 여기에 몰아서 import
import Kingfisher
import ManualLayout
import SnapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  // ⭐️⭐️⭐️ 싱글톤 클래스 프로퍼티 생성
  class var instance: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate  // AppDelegate.instance 로 접근 가능
  }

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let window = UIWindow(frame: UIScreen.main.bounds)  //윈도우 생성
    window.backgroundColor = .white //배경색 흰색으로
    window.makeKeyAndVisible()    // ⭐️ 코드로 윈도우 생성할 때 기본적으로 해줘야 함
    
    //let viewController = FeedViewController()
    //let viewController = LoginViewController()
    //let navigationController = UINavigationController(rootViewController: viewController) //navigationController 생성하여 FeedVC를 감쌈.
    //window.rootViewController = navigationController  //해당 navigationController를 rootViewController에 할당
    
    let viewController = SplashViewController()
    window.rootViewController = viewController  // 여기서 로그인 유무 판단하여 login or feed로 이동시킬지 결정할거임
    
    
    self.window = window
    
    return true
  }

  func presentLoginScreen(){
    let loginViewController = LoginViewController()
    let navigationController = UINavigationController(rootViewController: loginViewController)
    self.window?.rootViewController = navigationController
  }
  
  func presentMainScreen(){
    //
    //  UIApplication.shared.delegate as? Appdelegate <- LoginViewController에서 이렇게 Appdelegate에 접근 가능함. 이걸 싱글톤으로 생성해서 더 간단하게 변경 가능
    //
    
    
    /*
    let feedViewController = FeedViewController()
    let navigationController = UINavigationController(rootViewController: feedViewController) //feedVC를 wrapping하는 navi생성
    
    // ⭐️⭐️⭐️ tabbar 생성
    let tabBarController = UITabBarController()
    tabBarController.viewControllers = [navigationController] ⭐️
    //self.window?.rootViewController = navigationController ⭐️
    self.window?.rootViewController = tabBarController ⭐️
    */
    
    //변경!
    
    let tabBarController = MainTabBarController()
    self.window?.rootViewController = tabBarController
  }
}

