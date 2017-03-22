//
//  UserService.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import Alamofire
import ObjectMapper

struct UserService {
  
  //static 하면 struct 인스턴스 만들지 않아도 접근 가능
  static func me(completion: @escaping (DataResponse<User>) -> Void){  //⭐️⭐️@escaping : 이 클로져는 해당 함수의 스코프 안에서만 사용할 수 있게끔 설계되어있음. 이 클로져를 다른 곳에서 사용할 수 있다 라는 표시임. -> 다른 외부의 클로져에서도 이 클로져를 호출할 수 있음.
    let urlString = "https://api.graygram.com/me" // ⭐️⭐️⭐️ alamofire에서는 계속 세션 저장(쿠키에 저장)하므로 이렇게 요청해도 세션 확인 가능함.
    request(urlString)
      .validate(statusCode: 200..<400)
      .responseJSON{ response in
        let newResponse: DataResponse<User> = response
          .flapMap { value in  //성공했을 떄의 value
            if let user = Mapper<User>().map(JSONObject: value) {
              return .success(user)
            }else{
              return .failure(MappingError(from: value, to: User.self))
            }
          }
        completion(newResponse)
        /*
        switch response.result {
        case .success(let value):
          //DataResponse<Any> -> DataResponse<User>
          /*
          if let json = value as? [String: Any] {
            let user = User(JSON: json) //생성자
            // let user = Mapper<User>().map(JSON: json) 과 동일함
           ⭐️⭐️⭐️⭐️⭐️⭐️
          }
          */
          //Mapper<User>().map(JSONObject: <#T##Any?#>)
          if let user = Mapper<User>().map(JSONObject: value) { //⭐️⭐️⭐️ 이걸 사용하면 굳이 value를 [String: Any]로 캐스팅 하지 않아도 됨!
            let userResponse: DataResponse<User> = DataResponse(
              request: response.request,
              response: response.response,
              data: response.data,
              //result: Result<Value>,    //DataResponse<Any>로 정의되어있는 이유는 result 때문임.
              result: .success(user),
              timeline: response.timeline
            )
            completion(userResponse)
          }else{  //요청은 성공했지만 data를 통해 user에 mapping한 것이 실패한 경우
            
            let userResponse: DataResponse<User> = DataResponse(
              request: response.request,
              response: response.response,
              data: response.data,
              //result: Result<Value>,    //DataResponse<Any>로 정의되어있는 이유는 result 때문임.
              result: .failure(MappingError(from: value, to: User.self)), //failure에서는 erorr를 넘겨야 하는데 넘어오는 error는 없으므로, 우리가 만들어줘야 함
              timeline: response.timeline
            )
            completion(userResponse)
          }
        case .failure(let error):
          let userResponse: DataResponse<User> = DataResponse(
            request: response.request,
            response: response.response,
            data: response.data,
            //result: Result<Value>,    //DataResponse<Any>로 정의되어있는 이유는 result 때문임.
            result: .failure(error),
            timeline: response.timeline
          )
          completion(userResponse)

        }
      */
    }
  }
}

/*
 DataResponse<Any> -> DataResponse<User> 로 바꾸는 방법 참고
 
 
 import UIKit
 
 struct User {}
 
 enum Result<T> {  // ⭐️⭐️여기 T도 결정이 알아서 됨
  case success(T) // ⭐️⭐️여기 T가 결정되면
  case failure(Error)
 }
 
 enum UserResult {
  case success(User)
  case failure(Error)
 }
 
 struct DataResponse<T> {
  let result: Result<T>
 }
 
 DataResponse(result: Result.success("Hello")) 
 //⭐️⭐️⭐️⭐️따라서 여기서 .success의 타입을 결정하면 자동으로 Result의 제네릭 타입도 결정이 되게 되고, DataResponse의 제네릭 타입도 결정이 됨.
 DataResponse(result: Result.success(User()))
 
 let result = Result.success("Hello")
 switch result {
  case .success(let value):
  print("성공: \(value)")
  case .failure(let error):
  print("실패: \(error)")
 
 }
 
 
 let userResult = UserResult.success(User())
 switch userResult {
  case .success(let value):
  print("성공: \(value)")
  case .failure(let error):
  print("실패: \(error)")
 }

 */
