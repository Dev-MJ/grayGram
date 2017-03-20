//
//  LoginViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 06/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

//import Alamofire  // ⭐️ global scope인지 extension인지에 따라.

final class LoginViewController: UIViewController {
  
  // MARK: - UI
  
  // ⭐️⭐️ UI 관련 은 fileprivate로 지정 <- ui관련 속성은 다른 클래스에서 값을 변화시킬 수 있으므로..
  fileprivate let usernameTextField = UITextField()
  fileprivate let passwordTextField = UITextField()
  fileprivate let loginButton = UIButton()
  
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad(){
    super.viewDidLoad()
    self.view.backgroundColor = .white  // ⭐️ ViewController를 만들 때 기본적으로 하면 좋다. 기본은 투명색으로 되어있음.
    self.title = "Login"  //navi title
    
    // ID/PW
    // ⭐️ username / ⭐️ password
    // usernameField
    // passwordField
    
    self.usernameTextField.borderStyle = .roundedRect
    self.usernameTextField.placeholder = "Username"
    self.usernameTextField.font = UIFont.systemFont(ofSize: 14)
    self.usernameTextField.addTarget(self, action: #selector(textFieldDidEditingChanged), for: .editingChanged)
    // ⭐️ 첫글자 대문자, 자동완성기능 해제할 수 있음.
    self.usernameTextField.autocorrectionType = .no
    self.usernameTextField.autocapitalizationType = .none
    
    self.passwordTextField.borderStyle = .roundedRect
    self.passwordTextField.placeholder = "Password"
    self.passwordTextField.font = UIFont.systemFont(ofSize: 14)
    self.passwordTextField.isSecureTextEntry = true   // ⭐️ 마스킹처리
    self.passwordTextField.addTarget(self, action: #selector(textFieldDidEditingChanged), for: .editingChanged)
    
    self.loginButton.backgroundColor = self.loginButton.tintColor //tintColor : 모든 UIView에 정의되어 있는 속성. 
    self.loginButton.layer.cornerRadius = 5
    self.loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    self.loginButton.setTitle("Login", for: .normal)   //highlighted : 눌려있는 상태.
    self.loginButton.setTitle("눌림!", for: .highlighted)
    self.loginButton.addTarget(self, action: #selector(loginButtonDidTap), for: .touchUpInside)
    
    self.view.addSubview(self.usernameTextField)
    self.view.addSubview(self.passwordTextField)
    self.view.addSubview(self.loginButton)
    
    self.usernameTextField.snp.makeConstraints { make in
      make.left.equalTo(15) //왼쪽에서 15
      make.right.equalTo(-15)  // ⭐️ 오른쪽에서 15. offset은 무조건 오른쪽 아래로 계산되어짐.
      //make.top.equalTo(20 + 44) //20 : statusBar , 44: navigationBar
      make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(15) //topLayoutGuide : UIView. statusBar + naviBar높이만큼 위치하고 있는 녀석임
      make.height.equalTo(30) //textField는 자체 height있지만, Font로 인해 변할 수 있으므로 이렇게 지정해주자
    }
    
    self.passwordTextField.snp.makeConstraints { make in
      //make.left.equalTo(self.usernameTextField.snp.left)
      
//      make.left.equalTo(self.usernameTextField) //같은 속성이면 생략 가능
//      make.right.equalTo(self.usernameTextField)
//      make.height.equalTo(self.usernameTextField)
      
      make.left.right.height.equalTo(self.usernameTextField)  //세개가 같으므로
      make.top.equalTo(self.usernameTextField.snp.bottom).offset(15)
    }
    
    self.loginButton.snp.makeConstraints{ make in
      make.left.right.equalTo(self.usernameTextField)
      make.height.equalTo(40)
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(15)
    }
  }
  
  
  // MARK: - Action
  
  func textFieldDidEditingChanged(_ textField: UITextField){
    textField.textColor = .black
  }
  
  func loginButtonDidTap(){
    guard let username = self.usernameTextField.text, !username.isEmpty else {
      // ⭐️ 둘 다 통과 안되면 여기로
      self.usernameTextField.becomeFirstResponder()
      return
    }
    guard let password = self.passwordTextField.text, !password.isEmpty else {
      self.passwordTextField.becomeFirstResponder()
      return
    }
    
    //로그인 버튼 눌리고 나서 다시 눌리면안되니까.
    self.usernameTextField.isEnabled = false
    self.passwordTextField.isEnabled = false
    self.loginButton.isEnabled = false
    self.loginButton.alpha = 0.4  //보통 비활성화된 component의 alpha값은 0.4 사용
    
    AutoService.login(username: username, password: password){ response in
      switch response.result {
      case .success:
        print("로그인 성공!")
        //이제 세션에 로그인정보가 남아있는 상태임!!
        AppDelegate.instance?.presentMainScreen()
      case .failure:
        self.usernameTextField.isEnabled = true
        self.passwordTextField.isEnabled = true
        self.loginButton.isEnabled = true
        self.loginButton.alpha = 1
        
        //여기는 error만 떨어짐. 그래서 이 상태에서 response오는 json을 받아오려면 response로부터 꺼내와야 함
        //          JSONSerialization //json을 풀거나 만들 수 있는 녀석
        if let data = response.data,
          /*
           do {
           try JSONSerialization.jsonObject(with: data)//, options: JSONSerialization.ReadingOptions) throws <- ⭐️⭐️ error를 던질 수 있다는 의미. <- do try catch 사용해야 함
           } catch (let jsonError) {
           print("JSON Serialization failure : \(jsonError)")
           }
           */
          let json = try? JSONSerialization.jsonObject(with: data), // ⭐️⭐️ try? : 성공하면 그냥 그 값 반환, 에러이면 nil 반환. 따라서 ! 사용하면 nil반환할 때 crash
          let dict = json as? [String: Any],
          let errorInfo = dict["error"] as? [String: Any] {
          
          let field = errorInfo["field"] as? String
          if field == "username" {  // ⭐️⭐️ Any는 == 비교 불가
            self.usernameTextField.becomeFirstResponder()
            self.usernameTextField.textColor = .red
          }else if field == "password" {
            self.passwordTextField.becomeFirstResponder()
            self.passwordTextField.textColor = .red
          }
        }
      }
    }
    
    /*
    let urlString = "https://api.graygram.com/login/username"
    //Alamofire.request(url: URLConvertible)
    //global scope이므로 굳이 Alamofire에서 .request 안해줘도 됨
    let parameters: Parameters = ["username":username, "password":password]
    // ⭐️ Parameters? 는 typealias임.
    // ⭐️ encoding은 무시하면 기본값(urlencoding)을 사용함
    //request(urlString, method: .post, parameters: parameters, encoding: ParameterEncoding, headers: HTTPHeaders?)
    let headers: HTTPHeaders = ["Accept":"application/json"]  // ⭐️⭐️ http서버에게 난 이런 타입을 원해 라고 말하는 것. 이렇게 하면 서버에서 json을 내려줌
    request(urlString, method: .post, parameters: parameters, headers: headers)
      .validate(statusCode: 200..<400)  // ⭐️⭐️ 그래서 이렇게 status code에 대해 validation함. 200~399까지의 코드가 오면 success, 이외의 코드가 오면 failure로 간주
      .responseJSON{ response in
        switch response.result {
        case .success(let value): //Alamofire는 http status code에 대해 validateion하지 않음. 그냥 반응 오면 success임.
          print("로그인 성공! \(value)")
          //이제 세션에 로그인정보가 남아있는 상태임!!
          AppDelegate.instance?.presentMainScreen()
        case .failure(let error):
          
          self.usernameTextField.isEnabled = true
          self.passwordTextField.isEnabled = true
          self.loginButton.isEnabled = true
          self.loginButton.alpha = 1
          
          //여기는 error만 떨어짐. 그래서 이 상태에서 response오는 json을 받아오려면 response로부터 꺼내와야 함
//          JSONSerialization //json을 풀거나 만들 수 있는 녀석
          if let data = response.data,
            /*
            do {
              try JSONSerialization.jsonObject(with: data)//, options: JSONSerialization.ReadingOptions) throws <- ⭐️⭐️ error를 던질 수 있다는 의미. <- do try catch 사용해야 함
            } catch (let jsonError) {
              print("JSON Serialization failure : \(jsonError)")
            }
            */
            let json = try? JSONSerialization.jsonObject(with: data), // ⭐️⭐️ try? : 성공하면 그냥 그 값 반환, 에러이면 nil 반환. 따라서 ! 사용하면 nil반환할 때 crash
            let dict = json as? [String: Any],
            let errorInfo = dict["error"] as? [String: Any] {
            
            let field = errorInfo["field"] as? String
            if field == "username" {  // ⭐️⭐️ Any는 == 비교 불가
              self.usernameTextField.becomeFirstResponder()
              self.usernameTextField.textColor = .red
            }else if field == "password" {
              self.passwordTextField.becomeFirstResponder()
              self.passwordTextField.textColor = .red
            }
          }
          
          print("로그인 실패 \(error)")
          /*
          Optional({
            error =     {
              field = username;
              message = "User not registered";
            };
          })
          */
        }
    }
 */
  }  
}
