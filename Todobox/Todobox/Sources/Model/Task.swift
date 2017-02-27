//
//  Task.swift
//  Todobox
//
//  Created by Dev.MJ on 2017. 2. 15..
//  Copyright © 2017년 Dev.MJ. All rights reserved.
//

import Foundation

struct Task {
    var title : String
    //Task가 class이면 초기값 있어야함
    //struct는 해당 property에 대한 생성자를 자동으로 컴파일러가 생성해줌
    /* 이걸 자동으로 생성해줌
    init(title: String) {
        self.title = title
    }
     */
    var isDone: Bool
    
    init(title: String, isDone: Bool = false) {
        self.title = title
        self.isDone = isDone
    }
    
}




