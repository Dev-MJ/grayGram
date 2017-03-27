//
//  URLNavigationMap.swift
//  Graygram
//
//  Created by Dev.MJ on 27/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import URLNavigator

struct URLNavigationMap {
  
  //이걸 appdelegate에 호출해야 url과 VC의 mapping이 완료됨
  static func initialize() {
    /* ⭐️⭐️⭐️⭐️
    Navigator.map("grgm://post/<id>", PostViewController.self)
     -> 이런 url패턴에 매칭되는 VC를 PostViewController로 정함
     ⭐️⭐️해당 VC를 이렇게 매칭하기 위해서는 URLNavigable 이라는 protocol을 따라야 함
     
     Navigator.push("grgm://post/3")
     Navigator.present("grgm://post/3")
     */
    
    Navigator.map("grgm://post/<int:id>", PostViewController.self)  //Int형이라고 지정할 수 있음. id라는 name이, init?에서 values의 key값으로 사용됨
  }
}
