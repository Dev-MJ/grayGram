//
//  TaskEditViewController.swift
//  Todobox
//
//  Created by Dev.MJ on 2017. 2. 15..
//  Copyright © 2017년 Dev.MJ. All rights reserved.
//

import UIKit

extension Notification.Name {
  static var taskDidAdd: Notification.Name { //extension에는 저장변수 설정 못하므로 get 설정
    return Notification.Name.init("taskDidAdd")
  }
  
  //이렇게 간결하게 쓸 수도 있음
  static var taskDidAdd2: Notification.Name { return .init("taskDidAdd2") }
}


class TaskEditViewController: UIViewController {
    
    @IBOutlet weak var titleInput : UITextField!    //implicitly unwrapped optional
    
    /*
    weak var delegate: TaskEditViewControllerDelegate?  //weak 약한 참조 : 레퍼런스 카운트를 올리지 않음. 참조타입에서만 사용가능
    */
    
    //callback으로 사용하기 - 클로저 이용
    var didAddTask: ((Task) -> Void)?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.titleInput.becomeFirstResponder()
    }
    
    /// 'Done' 버튼이 선택된 경우 호출되는 메서드입니다.
    @IBAction func doneButtonDidTap(){
      if let title = self.titleInput.text, !title.isEmpty {
        let newTask = Task(title: title)    //이녀석을 TaskListViewController에 전달해줘야 등록이 됨
            
          
        /* newTask를 TaskListViewController에 전달해주는 방법
       
       
        /* 방법 1 - 비추 */   //TaskListVC에서만 가능한 너무 제한적인 코드임
        print(self.presentingViewController)
        //UINavigationController가 나옴. 이녀석은 self를 띄운 VC인데 이 VC는 TaskListVIewController. 그런데 TaskListViewController는 UINavigationController라는 컨테이너 안에 있으므로 UINavigationController가 뜸. 따라서 TaskListViewController는 UINavigationController라는 컨테이너의 stack의 첫번째 VC일 것.
        if let navigationController = self.presentingViewController as? UINavigationController {
            if let taskListViewController = navigationController.viewControllers.first as? TaskListViewController {
                taskListViewController.tasks.append(newTask)
                taskListViewController.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
        }
        */
        
        
        
        /**
        /* 방법 2 - Delegate - 메서드를 정의하는 object를 넘겨주는 방식 */
        self.delegate?.taskEditViewController(self, didAddTask: newTask)
        self.dismiss(animated: true, completion: nil)
        **/
      
      
        
        /**
        /* 방법 3 - callback - 메서드를 바로 넘겨주는 방식 */
        self.didAddTask?(newTask)
        self.dismiss(animated: true, completion: nil)
        **/
        
        
        
        /* 방법 4 - noti 이용 */
        //NSNotificationCneter.defaultCenter().post("이벤트네임") <- swift2.0
        NotificationCenter.default.post(name: .taskDidAdd, object: self, userInfo: ["task":newTask])
                                                          //object: 어떤 녀석이 noti를 발생시켰니?
        //NSNotification.Name : NSNotification을 extension한 내부의 struct.
        //NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil, userInfo: nil)
        
        
        
        self.dismiss(animated: true, completion: nil)
        
        
      }else{
        // text field를 좌우로 흔들 예정
        // frame : view의 x,y width, height

        //1. 재귀 , 2. UIView를 extension
        UIView.animate(
          withDuration: 0.03,
          animations: {
            self.titleInput.frame.origin.x -= 10
          },
          completion: { _  in
            UIView.animate(
              withDuration: 0.03,
              animations: {
                self.titleInput.frame.origin.x += 20
              },
              completion: { _ in
                UIView.animate(
                  withDuration: 0.03,
                  animations: {
                    self.titleInput.frame.origin.x -= 20
                  },
                  completion: { _ in
                    UIView.animate(
                      withDuration: 0.03,
                      animations: {
                        self.titleInput.frame.origin.x += 20
                      },
                      completion: { _ in
                        UIView.animate(
                          withDuration: 0.03,
                          animations: {
                            self.titleInput.frame.origin.x -= 20
                          },
                          completion: { _ in
                            UIView.animate(
                              withDuration: 0.03,
                              animations: {
                                self.titleInput.frame.origin.x += 10
                              },
                              completion: { _ in
                                
                              }
                            )
                          }
                        )
                      }
                    )
                  }
                )
              }
            )
          }
        )
    }
  }
  
  @IBAction func cancelButtonDidTap(){
    //alert + actionSheet 되어서 UIAlertController가 됨
    let alertController = UIAlertController(title: /*"정말 취소 할까요?",*/ NSLocalizedString("new_task_cancel_alert_title", comment: ""),
                                            message: "작성중이던 내용이 유실됩니다",
                                            preferredStyle: .alert
                                            )
    alertController.view.tintColor = .purple  //tintColor : 모든 UIView가 갖고 있는 속성
    alertController.addAction(UIAlertAction(title: "아니오", style: .default, handler: { _ in }))
    alertController.addAction(UIAlertAction(title: "네", style: .destructive, handler: { _ in
      self.dismiss(animated: true, completion: nil)
    }))
    self.present(alertController, animated: true, completion: nil)
                    //띄울 VC, animation, completion
    
    //Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: "Cancel", value: nil, table: nil)  //언어별 cancel이 적용됨
  }
}

/*
// MARK: - TaskEditViewControllerDelegate

protocol TaskEditViewControllerDelegate : class{    //: class를 넣어주면 class에서만 쓰일 수 있다 -> 참조타입으로 다뤄짐. 이게 없으면 값타입으로 다뤄짐
                                    //첫번째 param : 해당 VC , 두번째 param : 하는 일
    func taskEditViewController(_ taskEditViewController: TaskEditViewController, didAddTask task: Task)
}
 */
