//
//  String+BoundingRect.swift
//  Graygram
//
//  Created by Dev.MJ on 15/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

/*
import Foundation
import CoreGraphics //CGRect 이용하기 위함
*/
import UIKit  //UIFont. Foundation과 CoreGraphics 모두 포함하고 있다.

extension String {
  
  func boundingRect(width: CGFloat, font: UIFont, numberOfLines: Int = 0) -> CGRect {
    //boundingRect 간결하게 만들 func
    let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
    //랜더링 될 string의 최대 크기. numberOfLines에 의해 좌우됨. height는 일단 무한이라 가정
    
    var rect = self.boundingRect(with: size,
                             options: [.usesFontLeading, .usesLineFragmentOrigin],
                             attributes: [NSFontAttributeName: font],
                             context: nil)
    rect.size.width = ceil(rect.width)
    if numberOfLines > 0 {
      rect.size.height = min(rect.height, font.lineHeight * CGFloat(numberOfLines))
    }
    rect.size.height = ceil(rect.height)
    
    return rect
  }
  
  func height(width: CGFloat, font: UIFont, numberOfLines: Int = 0) -> CGFloat {
    //string의 height 계산 func
    return self.boundingRect(width: width, font: font, numberOfLines: numberOfLines).height
  }
}
