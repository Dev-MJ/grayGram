//
//  DataResponse+MapResult.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import Alamofire

extension DataResponse {
  
  // (Value) -> Result<T>
  
  func flapMap<T>(_ transform: (Value) -> Result<T>) -> DataResponse<T> {
    //이 extension이 정의하는 DataResponse의 제네릭타입과, flatMap이 반환하는 DataREsponse의 타입이 다르게 하기 위해 <T> 추가
    let result: Result<T>
    // TODO: result
    switch self.result {
    case .success(let value):
      result = transform(value) //transform이라는 클로져는 Result<T>를 반환하므로, 바로 넣을 수 있음
    case .failure(let error):
      result = .failure(error)
    }
    return DataResponse<T>(request: self.request,
                        response: self.response,
                        data: self.data,
                        result: result,
                        timeline: self.timeline)
  }
}
