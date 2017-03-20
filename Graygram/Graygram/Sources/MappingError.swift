//
//  MappingError.swift
//  Graygram
//
//  Created by Dev.MJ on 20/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import ObjectMapper

struct MappingError: Error, CustomStringConvertible { //CustomStringConvertible:
 
  let description: String //객체를 통째로 호출시, 이녀석이 호출됨 ex: print(MappingError()) 하면 description이 호출됨
  
  init(from: Any?, to: Any.Type){
    //어떤 데이터를 갖고 mapping을 시도했는지, 어떤 타입으로 mapping을 하려 했는지 알려주기 위해, 생성자에서 각각의 변수들을 받는다
    self.description = "Failed to map \(from) to \(to)"
  }
}
