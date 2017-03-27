//
//  AuthService.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import Alamofire

struct AutoService {
  
  static func login(username: String,
                    password: String,
                    completion: @escaping (DataResponse<Void>) -> Void) {
    
    let urlString = "https://api.graygram.com/login/username"
    let parameters: Parameters = ["username":username, "password":password]
    let headers: HTTPHeaders = ["Accept":"application/json"]
    Alamofire.request(urlString, method: .post, parameters: parameters, headers: headers)
      .validate(statusCode: 200..<400)
      .responseJSON{ response in
        let newResponse: DataResponse<Void> = response
          .flapMap{ value in
            print("좋아요 호출시 value : \(value)")
            return .success(Void())
        }
        completion(newResponse)
    }
  }
  
  static func logout(){
    let storage = HTTPCookieStorage.shared  //cookie 목록 받아옴
    if let cookies = storage.cookies { //cookies 배열 돌면서 모두 제거
      for cookie in cookies {
        storage.deleteCookie(cookie)
        print("쿠키 학제 :\(cookie.name)")
      }
    }
  }
}
