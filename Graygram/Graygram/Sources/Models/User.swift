//
//  User.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import ObjectMapper

struct User: Mappable {
  var id: Int!
  var username: String!
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    self.id <- map["id"]
    self.username <- map["username"]
  }
}
