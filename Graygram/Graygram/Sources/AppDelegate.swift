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
import URLNavigator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var destination: URL? //앱이 실행이 된 후, 앱이 모두 초기화 된 뒤에(feedVC 볼 수 있는 단계에 갔을 때)이 걸로 destinationVC를 결정
  
  // ⭐️⭐️⭐️ 싱글톤 클래스 프로퍼티 생성
  class var instance: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate  // AppDelegate.instance 로 접근 가능
  }

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    URLNavigationMap.initialize()
    
    //⭐️⭐️⭐️⭐️⭐️ 모든 navigationBar의 tintColor를 변경!!!
    UINavigationBar.appearance().tintColor = .black
    UIBarButtonItem.appearance().tintColor = .black //⭐️⭐️⭐️⭐️뒤로가기 버튼 변경!!!
    UITabBar.appearance().tintColor = .black  //⭐️⭐️⭐️⭐️tabBar 버튼 변경!!!
    
    
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
    
    if let url = launchOptions?[.url] as? URL {  //Any -> URL
      //Navigator.present(url, wrap: true)  //바로 이렇게 하면 해당 postVC가 뜬 뒤에, splashVC에 의해 FeedVC가 떠버림. 따라서 destination이라는 변수를 이용하여, feedVC가 뜬 뒤에 destination으로 목적지 VC를 띄움
      self.destination = url
    }
    
    return true
  }
  
  //⭐️⭐️⭐️ 앱이 background에 있다가 URL을 통해 foreground로 전환된 경우
  func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    if Navigator.present(url, wrap: true) != nil {
      return true   //우리가 처리할 수 있는 url인 경우, true를 return해줘야 해당 url은 이 앱에서 처리 가능하다는 것을 전달할 수 있음
    }
    return false
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
    
    if let destination = self.destination {
      Navigator.present(destination, wrap: true)
    }
  }
}

