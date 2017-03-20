//
//  PostEditorMessageCell.swift
//  Graygram
//
//  Created by Dev.MJ on 15/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class PostEditorMessageCell: UITableViewCell {
  
  fileprivate struct Font {
    static let textViewFont = UIFont.systemFont(ofSize: 14)
  }
  
  var textDidChange: ((String) -> Void)?
  
  fileprivate let textView = UITextView()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.textView.font = Font.textViewFont
    self.textView.delegate = self
    self.contentView.addSubview(self.textView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(message: String){
    self.textView.text = message
  }
  
  //유동적 높이 변환 위해 message도 받는다.
  class func height(width: CGFloat, message: String) -> CGFloat {
    
    let minimumHeight = ceil(Font.textViewFont.lineHeight * 3)  //초기에 message가 비어있을 경우, 적당한 높이를 부여해야 하므로
    let messageHeight = message.height(width: width, font: Font.textViewFont)
    //기본적으로 UITextView는 위 아래로 10px씩 여백이 들어가있음. 따라서 20px 더해야함
    
    return max(minimumHeight, messageHeight) + 20
  }
  
  override func layoutSubviews(){
    super.layoutSubviews()
    self.textView.frame = self.contentView.bounds
  }
}

extension PostEditorMessageCell: UITextViewDelegate {
  //sholdbeginediting : 입력되는 text가 textView에 반영될지 말지 결정 ex: 글자수 제한
  //sholdendediting : enter 키
  func textViewDidChange(_ textView: UITextView) {
    //⭐️⭐️textView의 내용이 변경될 때 이를 VC에 알려줄것!!! - callback closure로 하자!
     self.textDidChange?(textView.text)
  }
}
