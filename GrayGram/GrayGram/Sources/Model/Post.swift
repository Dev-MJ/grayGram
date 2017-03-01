//
//  Post.swift
//  GrayGram
//
//  Created by Dev.MJ on 01/03/2017.
//  Copyright © 2017 HelloMJ. All rights reserved.
//

import ObjectMapper

struct Post: Mappable {
  
  var username: String!
  var userPhotoID: String!
  
  var id: Int!
  var photoID: String!
  var message: String?
  
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    
    self.userPhotoID <- map["user.photo.id"]
    self.username <- map["user.username"]
    
    self.id <- map["id"]
    self.photoID <- map["photo.id"]
    self.message <- map["message"]
    
  }
}
