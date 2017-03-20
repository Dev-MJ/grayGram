//
//  Feed.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import ObjectMapper

struct Feed: Mappable {
  
  var posts: [Post]!
  var nextURLString: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    self.posts <- map["data"]
    self.nextURLString <- map["paging.next"]
  }
  
}
