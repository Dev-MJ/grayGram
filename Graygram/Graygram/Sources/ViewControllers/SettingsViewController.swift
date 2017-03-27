//
//  SettingsViewController.swift
//  Graygram
//
//  Created by Dev.MJ on 27/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import SafariServices
import UIKit  //UIWebView

//⭐️⭐️⭐️⭐️⭐️⭐️
//UIWebView : UIKit. 이제 안씀
//WkWebView : WebKit. UIView 상속받는 녀석. 뒤로가기 등등의 기능 전부 다 구현해줘야 함
//SFSafariViewController : UIViewController 상속받음. 브라우져가 갖는 기능 다 갖고 있음. 세션이 safari와 공유됨!


final class SettingsViewController: UIViewController {
  
  //Section Model ⭐️⭐️⭐️
  /*
   Section과, 그 안에 들어갈 item들을 추상화
   */
  struct Section {
    var items: [SectionItem]
  }
  
  enum SectionItem {
    case about
    case openSource
    case icons
    case version
    case logout
  }
  
  //⭐️⭐️⭐️⭐️
  struct CellData {
    var text: String
    var detailText: String?
  }
  
  fileprivate let tableView = UITableView(frame: .zero, style: .grouped)
  var didSetupConstraints = false //⭐️⭐️⭐️makeConstraints가 한 번만 호출 되도록 하기 위한 변수!!
  
//  fileprivate var sections: [Section] = [Section(items: [.version, .logout])] //하나의 섹션에 version과 logout이 존재
  fileprivate var sections: [Section] = [Section(items: [.about, .openSource, .icons]),
                                         Section(items: [.version]),
                                         Section(items:[.logout])] //2개 섹션에 version과 logout이 하나씩
  
  //메모리가 꽉 차서 메모리 정리 된 후에도 viewdidload는 다시 호출 될 수 있다. 따라서 autolayout 설정 코드들은 여기에는 적합치 않다!!!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Settings"
    self.tableView.dataSource = self
    self.tableView.delegate = self
    //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    self.tableView.register(SettingCell.self, forCellReuseIdentifier: "cell")
    self.view.addSubview(self.tableView)
    self.view.setNeedsUpdateConstraints() //⭐️⭐️이걸 해야 updateViewConstraints 가 호출이 됨!!

  }
  
  //⭐️⭐️⭐️레이아웃 전에 한 번 호출, constraints가 바뀔 때 호출 or constraint가 바뀌어야 만 할 때 호출⭐️⭐️⭐️
  override func updateViewConstraints() {
    
    if !self.didSetupConstraints {
      self.didSetupConstraints = true
      self.tableView.snp.makeConstraints{ make in
        make.edges.equalToSuperview()
      }
    }
    super.updateViewConstraints() //super를 나중에.
  }
  
  func cellData(for sectionItem: SectionItem) -> CellData { //해당 indexPath에 쓰일 CellData를 반환하는 method
    
    switch sectionItem {
    case .about:
      return CellData(text: "Graygram에 관하여", detailText: nil)
    case .openSource:
      return CellData(text: "오픈소스 라이센스", detailText: nil)
    case .icons:
      return CellData(text: "아이콘 출처", detailText: "icons8.com")
    case .version:
      //⭐️runtime에 버전 정보를 얻어올 수 있음⭐️
      //Bundle  : 앱에 같이 포함되어 올라간 리소스에 접근할 수 있는 클래스
      //Info.plist에 적혀있는 정보를 얻어옴.상수로 되어있지 않으므로 하드코딩을 통해 꺼내와야 함
      let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
      return CellData(text: "현재 버전", detailText: version)
    case .logout:
      return CellData(text: "로그아웃", detailText: nil)
    }
  }
}


extension SettingsViewController: UITableViewDataSource {
 
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.sections.count
  }
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return self.sections[section].items.count
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let sectionItem = self.sections[indexPath.section].items[indexPath.row]
//    switch sectionItem {
//    case .about:
//      cell.textLabel?.text = "Graygram에 관하여"
//      cell.detailTextLabel?.text = nil
//    case .openSource:
//      cell.textLabel?.text = "오픈소스 라이센스"
//      cell.detailTextLabel?.text = nil
//    case .icons:
//      cell.textLabel?.text = "아이콘 출처"
//      cell.detailTextLabel?.text = "icons8.com"
//    case .version:
//      cell.textLabel?.text = "현재 버전"
//      cell.detailTextLabel?.text = "0.0.0"
//    case .logout:
//      cell.textLabel?.text = "로그아웃"
//    }
    let cellData = self.cellData(for: sectionItem)
    cell.textLabel?.text = cellData.text
    cell.detailTextLabel?.text = cellData.detailText
    cell.accessoryType = .disclosureIndicator //⭐️⭐️⭐️ 꺽쇄가 생김
    return cell
  }
}


extension SettingsViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let sectionItem = self.sections[indexPath.section].items[indexPath.row]
    switch sectionItem {
    case .about:
      break
    case .openSource:
      break
    case .icons:
      let url = URL(string: "https://icons8.com")!
      let viewController = SFSafariViewController(url: url)
      self.present(viewController, animated: true, completion: nil)
    case .version:
      break
    case .logout:
      //로컬에 남아있는 세션쿠키 모두 삭제.
      AutoService.logout()
      //이제 로그인 화면으로 보내자
      AppDelegate.instance?.presentLoginScreen()
      break
    }
  }
}


// 현재 버전에 버전정보를 넣기 위해 새로운 cell을 만들자. cell의 style은 value1임.
final class SettingCell: UITableViewCell {
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


