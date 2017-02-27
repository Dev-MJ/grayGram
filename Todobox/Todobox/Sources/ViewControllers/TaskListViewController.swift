//
//  TaskViewController.swift
//  Todobox
//
//  Created by Dev.MJ on 2017. 2. 13..
//  Copyright © 2017년 Dev.MJ. All rights reserved.
//

import UIKit

class TaskListViewController: UIViewController {

  // MARK: Properties
  
  /*
  var tasks: [Task] = [
      Task(title: "청소하기"),    //Task의 init에서 isDone의 default값을 false로 지정해버리면 여기서는 isDone 안설정해줘도 됨
      Task(title: "빨래하기"),
      Task(title: "설거지하기"),   //마지막에는 , 붙여도 됨
  ]
 */
  var tasks: [Task] = [] {
    didSet {
      self.saveAll()  //saveAll()이 호출될때를 보면 항상 tasks가 변하는 부분임 따라서 이렇게 할 수 있음!!!!!
    }
  }
  
  // MARK: UI
  
  @IBOutlet var editButton : UIBarButtonItem!
  let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
  @IBOutlet var tableView: UITableView! //inplicitly unwrapped option
  
  deinit {
    //addObserver하면 지워줘야 함
    NotificationCenter.default.removeObserver(self) //이 VC에 관련된 observer가 모두 제거
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let navigationController = segue.destination as? UINavigationController,
          let taskEditViewcontroller = navigationController.viewControllers.first as? TaskEditViewController {
        
          /*방법 2 - delegate */
          //taskEditViewcontroller.delegate = self
 
        
          /* 방법3 - callback
          taskEditViewcontroller.didAddTask = { (task: Task) -> Void in
              self.tasks.append(task)
              self.tableView.reloadData()
          }
          */
      }
  }
  
  
  //nib : 인터페이스 빌더 관련.
  override func awakeFromNib() {
    //storyboard 와 관련된.......
    super.awakeFromNib()
    NotificationCenter.default.addObserver(self, selector: #selector(taskDidAdd), name: .taskDidAdd, object: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.doneButton.target = self
    self.doneButton.action = #selector(doneButtonDidTap)
    
    //VC가 self.view를 갖고 있는데, 이 view가 초기화 된 직후에 실행됨.
    //메모리가 부족해서 view가 정리 된 후에 다시 호출 될 수 있음
    if let dics = UserDefaults.standard.array(forKey: "tasks") as? [[String: Any]] {
      /*
      for dic in dics {
        if let title = dic["title"] as? String,
          let isDone = dic["isDone"] as? Bool {
          self.tasks.append(Task(title: title, isDone: isDone))
        }else{
          //map을 사용하면 무조건 task를 반환해야 하므로 이렇게 분기처리를 할 수 없음.
          //따라서 이럴 땐 flatMap - 반환시에 nil인 녀석이 있으면 빼버림
        }
      }
      */
      
      /*
      self.tasks = dics.map { (value: [String: Any]) -> Task in return Task(title: value["title"] as? String ?? "", isDone: value["isDone"] as? Bool ?? false) }
      self.tasks = dics.map { val in Task(title: val["title"] as? String ?? "", isDone: val["isDone"] as? Bool ?? false)}
      self.tasks = dics.map { Task(title: $0["title"] as? String ?? "", isDone: $0["isDone"] as? Bool ?? false) }
       */

      self.tasks = dics.flatMap { (dic: [String: Any]) -> Task? in
        if let title = dic["title"] as? String,
          let isDone = dic["isDone"] as? Bool {
            return Task(title: title, isDone: isDone)
        }else{
          return nil
        }
      }
      self.tableView.reloadData()
    }
    
    
    
    //코코아 컨벤션
    /*
     func name() -> String {
     }
     
     func setName(name){
     }
     */
    
  }
  
  func taskDidAdd(_ notification: Notification){  //notification handler는 parameter 하나 가질 수 있음 - Notification객체 - 이 안에 userInfo있음
    guard let task = notification.userInfo?["task"] as? Task else { return }
    self.tasks.append(task)
    self.tableView.reloadData() //화면에 보이는 cell만 다시 그림
    
    //primitive 한 타입만 저장 가능
    //[Task] -> [String: Any]
    /*
     let dics: [[String: Any]] = self.tasks.map { (task: Task) -> [String: Any] in return ["title":task.title, "isDone":task.isDone] }
     */
    
    /* 함수화 해버림
    let dics: [[String: Any]] = self.tasks.map{ ["title": $0.title, "isDone": $0.isDone] }
    UserDefaults.standard.set(dics, forKey: "tasks")
    UserDefaults.standard.synchronize()
     */
    
    
    //self.saveAll()
  }
  
  
  
  @IBAction func editButtonDidTap(){
    //edit -> done -> edit  이런 toggle 기능 구현
    self.navigationItem.leftBarButtonItem = self.doneButton
    //self.tableView.isEditing = true //이렇게 하면 애니메이션 효과가 없음
    self.tableView.setEditing(true, animated: true) //애니메이션 효과 주기 위함
  }
  func doneButtonDidTap(){
    self.navigationItem.leftBarButtonItem = self.editButton
    self.tableView.setEditing(false, animated: true)
  }
}


// MARK: - UITableViewDataSource
// MARK: UITableViewDataSource

extension TaskListViewController : UITableViewDataSource {
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return tasks.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      //let cell = UITableViewCell()    // < - 매번 새로운 새로운 cell이 만들어짐. => tableView에 cell을 등록하고 그 객체를 꺼내와서 재사용함!!!
      let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
      let task = self.tasks[indexPath.row]
      cell.textLabel?.text = task.title
      if task.isDone {
          cell.accessoryType = .checkmark
      }else{
          cell.accessoryType = .none  //cell이 재사용되기 때문에 꼭 else로 처리해줘야 함
      }
      return cell
  }
  
  func saveAll(){
    let dics: [[String: Any]] = self.tasks.map{ ["title": $0.title, "isDone": $0.isDone] }
    UserDefaults.standard.set(dics, forKey: "tasks")
    UserDefaults.standard.synchronize()
  }
}


// MARK: - UITableViewDelegate

extension TaskListViewController : UITableViewDelegate { //all optional method
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      var task = self.tasks[indexPath.row]    //task 복제.
      task.isDone = !task.isDone  // 이렇게 바꿔도 self.tasks[indexPath.row] 의 isDone은 안바뀜
      self.tasks[indexPath.row] = task    //따라서 여기에 다시 이렇게 넣어줘야 함 => struct이므로!!!!!!
      
      //UI를 변경해줘야 한다!
      //1. tableView.reloadData()
      //2. 값이 바뀐 cell을 tableView에 알려줘서, 해당 indexPath의 cell만 update
      //  ㄴ> tableView.reloadRows(at:, with:)
      tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  //edit -> delete 누를 시 호출되는 메서드
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  
    self.tasks.remove(at: indexPath.row)
    //self.tableView.reloadData() //지우고 이렇게 업데잍 하면 애니메이션 없음
    self.tableView.deleteRows(at: [indexPath], with: .automatic)
    
    //self.saveAll()
  }
  
  //editing 모드일 때 해당 indexPath의 cell을 옮길 수 있니 없니 bool 반환
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  //이녀석 구현해야 옮길 수 있는 부분이 우측에 나옴
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    //sorceIndexPath : 출발지점
    //destinationIndexPath : 목적지점
    var tasks = self.tasks
    let removedTask = tasks.remove(at: sourceIndexPath.row)
    tasks.insert(removedTask, at: destinationIndexPath.row) //remove 된 녀석을 insert
    self.tasks = tasks
    
    //self.saveAll()
  }
}

/*
// MARK: - TaskEditViewControllerDelegate

extension TaskListViewController: TaskEditViewControllerDelegate {
    func taskEditViewController(_ taskEditViewController: TaskEditViewController, didAddTask task: Task) {
        self.tasks.append(task)
        self.tableView.reloadData()
    }
}
 */
