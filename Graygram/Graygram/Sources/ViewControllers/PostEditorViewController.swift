//
//  PostEditorViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 15/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class PostEditorViewController: UIViewController {
  
  fileprivate let image: UIImage
  fileprivate var message: String = ""
  
  fileprivate let tableView = UITableView(frame: .zero, style: .grouped)  //이렇게 하면 위쪽 여백이 생김. section 별로 묶어주는 style
  fileprivate let progressView = UIProgressView()
  
  //crop된 이미지를 생성자로 전달받음
  init(image: UIImage) {
    self.image = image  //⭐️⭐️⭐️위의 이미지의 초기값을 여기서. super 클래스의 생성자 호출하기 전에. <- 이렇게 하면 위의 변수에 바로 초기화 안시켜줘도 됨
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad(){
    super.viewDidLoad()
    
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonItemDidTap))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemDidTap))
    
    self.tableView.delegate = self
    self.tableView.dataSource = self
    //Class.self : 클래스에 대한 reference
    self.tableView.register(PostEditorImageCell.self, forCellReuseIdentifier: "imageCell")
    self.tableView.register(PostEditorMessageCell.self, forCellReuseIdentifier: "messageCell")
    
    self.progressView.isHidden = true //done 누르기 전에는 Hidden처리
    
    self.view.addSubview(self.tableView)
    self.view.addSubview(self.progressView)
    
    self.tableView.snp.makeConstraints{ make in
      make.edges.equalToSuperview()
    }
    
    //⭐️자기 자신의 높이 갖고 있음
    self.progressView.snp.makeConstraints{ make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.topLayoutGuide.snp.bottom)  //⭐️⭐️naivgationBar의 하단에 붙어야 하므로.
    }
    
    
    
    //NotificationCenter는 defaultCenter라느 싱글톤 object 제공
    //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    //⭐️⭐️⭐️keyboard의 frame이 변하기 직전에 호출되는 noti. 이거 하나로 퉁 치면 된다!
    //Notification.Name.UIKeyboardWillChangeFrame
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    
  }
  
  
  // MARK: Notifications
  
  func keyboardWillChangeFrame(_ notification: Notification){
    //⭐️⭐️⭐️⭐️
    //UIKeyboardFrameBeginUserInfoKey : keyboard Frame이 변경되기 직전의 frame을 얻을 수 있음
    //UIKeyboardFrameEndUserInfoKey : keyboard Frame이 어떤 frame으로 변경될 지 알 수 있음
    //UIKeyboardAnimationDurationUserInfoKey : keyboard의 animation이 몇 초 짜리인지
    guard let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect,
      let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
    
    let keyboardVisibleHeight = UIScreen.main.bounds.height - keyboardFrame.origin.y  //실제 키보드가 화면에 그려지는 높이 계산
    UIView.animate(withDuration: animationDuration){
      //⭐️⭐️⭐️contentInset을 이용해 tableView의 contentInset Bottom을 변경해준다. -> scroll되는 영역을 더 아래로 내림
      //self.tableView.contentInset.bottom = keyboardFrame.height //⭐️⭐️키보드의 높이는 항상 있음. y좌표가 움직여서 보였다 안보였다 하는것. 따라서 화면에 보이는 키보드의 높이를 해야함
      self.tableView.contentInset.bottom = keyboardVisibleHeight
      self.tableView.scrollIndicatorInsets.bottom = keyboardVisibleHeight //⭐️⭐️scrollIndicator의 inset도 조절해주면 자연스러운 UI가 됨
      
      //keyboard가 올라올 때만 화면이 올라가야 하므로.
      if keyboardVisibleHeight > 0 {
        let indexPath = IndexPath(row: 1, section: 0)  //messageCell
        self.tableView.scrollToRow(at: indexPath, at: .none, animated: false) //해당 cell이 화면의 어떤 위치에 오게끔 스크롤 할 것인가? .none: 화면에 보여지게끔만
      }
    }
  }
  
  
  // MARK: Action
  
  func cancelBarButtonItemDidTap(){
    _ = self.navigationController?.popViewController(animated: true)
  }
  
  func doneBarButtonItemDidTap(){
    //미디어의 경우 이런 쿼리파라메터로 넘길 수가 없음 get - /foo?bar=Hello&baz=World
    // post의 경우 urlencoded 사용하면 url은 /foo , body에 bar=Hello&baz=World 이렇게 쿼리파라메터 형식으로넘어가는것. 따라서 이것도 미디어에는 부적합
    
    self.progressView.isHidden = false
    
    
    PostService.create(image: self.image,
                       message: self.message,
                       progress: { [weak self] progress in  //⭐️⭐️⭐️ 약한참조!! => 넘길 때 refCount를 증가시키지 않음
                        // ⭐️⭐️⭐️⭐️self: 약한 참조가 걸리면 PostEditorViewController? 로 optional이 됨!!
//                        self.progressView.progress =
                        self?.progressView.progress =
                        Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                       },
                       completion: { [weak self] response in
                        guard let strongSelf = self else { return }
                        //⭐️⭐️guard let `self` = self else { return }  이렇게 `` 사용하면 아래에서 그대로 self 사용 가능
                        switch response.result {
                        case .success(let post):
                          NotificationCenter.default.post(name: .postDidCreate,
                                                          //object: self, //누가 이 noti를 발생시켰니
                                                          object: strongSelf,
                                                          userInfo: ["post":post])
                        //self.dismiss(animated: true, completion: nil)
                        strongSelf.dismiss(animated: true, completion: nil)
                        case .failure(let error):
                          print("업로드 실패")
                        }
                       })
    /*
    // ⭐️⭐️⭐️⭐️Multipart FormData - 큰 파일을 바이너리로 보낼 수 있는 형식
    let urlString = "https://api.graygram.com/posts"
    let headers: HTTPHeaders = [
      "Accept":"application/json", // 난 이 타입으로 받겠따
    ]
    
    Alamofire.upload( //multipart formdata라는 인코딩 방식을 사용하기 때문에 upload 사용
      multipartFormData: { formData in
      //formData 생성
      /*UIImage를 jpeg로 변환하여 바이너리 데이터로 변환하는 함수(이미지, 퀄리티)*/
      if let imageData = UIImageJPEGRepresentation(self.image, 1) {
        //이미지 업로드시에는 이 append가 좋음
        formData.append(imageData, withName: "photo"/* api에서 이미지 네임을 이렇게 받게끔 만들어져있으므로 */, fileName: "photo.jpg", mimeType: "image/jpeg")
      }
      /* string으로부터 data 생성 */
      if let messageData = self.message.data(using: .utf8) {
        formData.append(messageData, withName: "message"/* api에서 텍스트는 이 이름으로 받게끔 만들어놓음 */ )
      }
    },
    to: urlString,
    headers: headers,
    encodingCompletion: { encodingResult in //multipart formdata encoding의 결과가 encodingResult로 넘어옴
      switch encodingResult {
      case .success(let request, _, _ ):
        //Alamofire.request(url)
        request //api 요청
          /*
          .uploadProgress(closure: { (<#Progress#>) in
            <#code#>
          })
          */
          .uploadProgress{ progress in  //⭐️progress : 전체 task의 양과 현재 task의 양 다 갖고 있음
            print("\(progress.completedUnitCount) / \(progress.totalUnitCount)")
            //self.progressView.progress  //Float 타입. 0~1까지 지정 가능
            //.uploadProgress에서의 UnitCount는 Int64
            self.progressView.progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
          }
          .validate(statusCode: 200..<400)
          .responseJSON{ response in  //response도착이 완료된 시점에 responseJSON이 호출되는것.
            switch response.result {
            case .success(let value):
              print("업로드 성공 : \(value)")
              if let json = value as? [String: Any],
                let post = Post(JSON: json) {
                NotificationCenter.default.post(name: .postDidCreate,
                                                object: self, //누가 이 noti를 발생시켰니
                                                userInfo: ["post":post])
              }
              self.dismiss(animated: true, completion: nil)
            case .failure(let error):
              print("업로드 실패 : \(error)")
              self.progressView.isHidden = true
              self.progressView.progress = 0
            }
          }
      case .failure(let error):
        print("인코딩 실패 : \(error)")  // multipart formdata를 만들지 못한 경우
        self.progressView.isHidden = true
        self.progressView.progress = 0
      }
    })
 */
  }
}

extension PostEditorViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as!
        PostEditorImageCell
      cell.configure(image: self.image)
      return cell
    }else{
      let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as!
        PostEditorMessageCell
      cell.configure(message: self.message)
      cell.textDidChange = { text in
        //textView가 바뀔 때 마다 이녀석이 text를 받음
        self.message = text
        
        //⭐️⭐️⭐️⭐️포커스 잃지 않고 높이만 변경
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        
        //단점 :  reload할때마다 textView의 포커스가 사라짐.
//        self.tableView.reloadRows(at: <#T##[IndexPath]#>, with: <#T##UITableViewRowAnimation#>)
//        self.tableView.reloadData()
      }
      return cell
    }
  }
}

extension PostEditorViewController: UITableViewDelegate {
  
  //tableViewCell의 기본높이는 44!
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return PostEditorImageCell.height(width: tableView.width)
    }else{
      return PostEditorMessageCell.height(width: tableView.width, message: self.message)
    }
  }
}
