//
//  FeedService.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import Alamofire
import ObjectMapper

struct FeedService {
  
                                        //포스트에 대한 배열, 다음 요청 할 url 필요
  static func feed(paging: Paging, completion: @escaping (DataResponse<Feed>) -> Void){
    let urlString: String
    switch paging {
    case .refresh:
      urlString = "https://api.graygram.com/feed"
    case .next(let nextURLString):
      urlString = nextURLString
    }
    Alamofire.request(urlString)
      .responseJSON { response in //response: DataResponse<Any>
        //DataResponse<Any> -> DataResponse<Feed>
        let newResponse: DataResponse<Feed> = response
          .flapMap{ value in
            if let feed = Mapper<Feed>().map(JSONObject: value) { //value를 Feed에 mapping. 이게 자동으로 key - value 찾아서 되는거?
              return .success(feed)
            }else{
              return .failure(MappingError(from: value, to: Feed.self))
            }
        }
        completion(newResponse)
    }
  }
}

//기존 코드
/*
 switch response.result {
 case .success(let value):
  //value는 any이므로, 캐스팅 한다. -> 이 과정을 flatMap을 통해 없애는것!!
  guard let json = value as? [String: Any] else { break }
  if let data = json["data"] as? [[String: Any]] {
    [Post].init(JSONArray: data) ?? []
 
  }
 case .failure(let error):
 }
 */
