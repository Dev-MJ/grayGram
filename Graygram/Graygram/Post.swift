//
//  Post.swift
//  Graygram
//
//  Created by Dev.MJ on 22/02/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import ObjectMapper //import Foundation 대신

struct Post: Mappable { //Mappable protocol.
  
  var id: Int!
  var message: String?
  var photoID: String!  //objectmapper에서는 어쩔 수 없이 Implicity Unwrapped Optional 사용해야함
  
  var username: String!
  var userPhotoID: String?
  
  var isLiked: Bool!
  var likeCount: Int!

  // MARK : Mappable protocol
  
  init?(map: Map) {
    //init? : 실패할 수 있는 생성자 의미.
    //넘겨받은 map을 validate하기 위함.
    
  }
  mutating func mapping(map: Map) {
    //struct는 let으로 설정하면 속성 바꾸지 못함
    //mutating func는 구조체 속성을 변경할 수 있는 function을 의미.
    //let으로 설정하고 mutating을 호출하면 컴파일 에러 발생
    //ObjectMapper에서 <- 연산자를 정의했기 때문에 이렇게 사용 가능
    self.id <- map["id"]
    self.message <- map["message"]
    self.photoID <- map["photo.id"] //objectmapper에서는 .으로 하위에 접근 가능
    self.username <- map["user.username"]
    self.userPhotoID <- map["user.photo.id"]
    self.isLiked <- map["is_liked"]
    self.likeCount <- map["like_count"]
  }
}

// ⭐️⭐️
extension Notification.Name {
  /// Post에 좋아요 표시할 때 발송되는 Noti. userInfo에 ["postID": Post.id] 값이 필요. userInfo는 정적이 아니라 동적이므로 이렇게 표시해줘야 한다
  static var postDidLike: Notification.Name {
    //return Notification.Name.init("postDidLike")
    return .init("postDidLike")
  }
  /// Post에 좋아요 취소할 때 발송되는 Noti. userInfo에 ["postID": Post.id] 값이 필요.
  static var postDidUnlike: Notification.Name { return .init("postDidUnlike") }
}





// ⭐️⭐️ ImmutableMappble
// let 생성자가 끝나기 전에 초기값이 지정되어있어야 함
/*
 
  Mappable 사용하면 var만 써야함
 
 
 
 */
struct Post2: ImmutableMappable { //Mappable protocol.
  
  let id: Int  //let 사용 가능. let은 생성자가 끝나기 전에 초기값이 지정되어야 하므로 하단처럼 init에서 값을 부여함. 그러므로 ! 도 안쓸 수 있음
  
  init(map: Map) throws {
    self.id = try map.value("id") // 이렇게 값을 꺼내옴. 값이 없으면 생성자에서 error낸다.
  }
  
}
