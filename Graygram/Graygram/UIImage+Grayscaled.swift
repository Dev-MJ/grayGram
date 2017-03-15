//
//  UIImage+Grayscaled.swift
//  Graygram
//
//  Created by Dev.MJ on 13/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

extension UIImage {
  
  func grayscaled() -> UIImage? {
    // - ed : swift naming convention == 원본은 두고, 복사본을 return
    /*
     array.reverse()
     array.reversed()
     
     array.sort()
     array.sorted()
     */
    
    
    //Core Graphic Context : iOS에서 사용되는 Graphic kit
    //이미지를 그리는 context를 갖고 있다
    
    /*⭐️⭐️⭐️⭐️
    1. CGContext 생성 ( colorspace (cf: 포토샵) 설정 - gray로 만듦 -> 흑백으로 변환되는것.)
    2. CGContext에 명령 ( self - 이미지 자신 를 그려라)
    3. CGContext로부터 이미지 생성 (CGImage 라는 클래스로 생성됨)
    4. CGImage -> UIImage 변환
    */
    
    //1.
    guard let context = CGContext.init(data: nil,
                                 width: Int(self.size.width),       //어떤 크기의 iamgecontext만들것인지. 현 이미지의 size
                                 height: Int(self.size.height),
                                 bitsPerComponent: 8,
                                 bytesPerRow: 0,
                                 space: CGColorSpaceCreateDeviceGray(), //⭐️context의 colorspace 지정. rgb, cmyk, gray
                                 bitmapInfo: .allZeros
      )
      else { return nil }
    
    //2. uiimage로부터 cgImage그리기
    guard let inputCGImage = self.cgImage else { return nil }
    let imageRect = CGRect(origin: .zero, size: self.size)
    context.draw(inputCGImage, in: imageRect)  // ⭐️ in: 어떤 크기로 그릴 것인가. 보여질 이미지 크기
    
    //3. 
    guard let outputCGImage = context.makeImage() else { return nil }  //context에서 수행한(draw 등등) 결과물을 cgimage로 반환하는 녀석
    
    //4.
    return UIImage(cgImage: outputCGImage)
    
  }
}
