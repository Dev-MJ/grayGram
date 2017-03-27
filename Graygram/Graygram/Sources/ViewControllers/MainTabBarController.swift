//
//  MainTabBarController.swift
//  Graygram
//
//  Created by Dev.MJ on 08/03/2017.
//  Copyright © 2017 Dev.MJ. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {
  
  let feedViewController = FeedViewController()
  let settingsViewController = SettingsViewController()
  
  /// 탭바에 업로드 버튼 영역을 만들기 위한 가짜 뷰 컨트롤러
  let fakeViewController = UIViewController()
  
  init(){
    super.init(nibName: nil, bundle: nil)
    //⭐️⭐️
    self.delegate = self
    
    //self.fakeViewController.tabBarItem.image = UIImage(named: "icon-like")  //fakeVC에 해당하는 탭바 아이템 이미지 설정.
    //title 없고 이미지만 있을 것이기 때문에 이미지 좀 더 큰녀석으로 80px(@2x), 120px(@3x)
    self.fakeViewController.tabBarItem.image = #imageLiteral(resourceName: "tab-upload")  // 이렇게 title 없으면 이미지가 상단에 위치함(title 자리 비워놔서)
    self.fakeViewController.tabBarItem.imageInsets.top = 5 // ⭐️ top: 5 == 위에서 5만큼 내려옴 -> bottom도 5를 줘야 찌부가 안됨
    self.fakeViewController.tabBarItem.imageInsets.bottom = -5
    self.viewControllers = [UINavigationController(rootViewController: self.feedViewController),
                            UINavigationController(rootViewController: self.settingsViewController),
                            self.fakeViewController,] // navi로 감싸서 넣는다. appdelegate의 navi구현부분을 여기서 해줌!!!
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func presentImagePickerController(){
    print("이미지 피커 컨트롤러 띄워라")
    //⭐️⭐️⭐️ default ImagePickerController. 이렇게만 하면 에러남! 권한을 Info.plist에 설정해줘야 한다!!!!
    //Privacy - Photo Library Usage Description : String 에 경고창의 내용입력
    let imagePickerController = UIImagePickerController()
    
    //⭐️⭐️UIImagePickerControllerDelegate, UINavigationControllerDelegate 을 구현해야 할 수 있음
    imagePickerController.delegate = self
    
    self.present(imagePickerController, animated: true, completion: nil)  //present는 UIVC에 있는 함수이므로 tabBArController도 사용가능
  }
  
  func presentPostEditorViewController(image: UIImage, from: UINavigationController){
    let postEditorViewController = PostEditorViewController(image: image)
    //uiimagepickerViewController가 갖고 있는 navigationController에 띄워야 하므로, 해당 정보가 있어야 함. 그래서 from 추가
    from.pushViewController(postEditorViewController, animated: true)
  }
}


extension MainTabBarController: UITabBarControllerDelegate {
  
  // viewcontroller 전환 판단(true: VC 전환, false: 전환X)
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if viewController === self.fakeViewController { // ⭐️⭐️⭐️ === : AnyObject(모두 reference type)에만 적용가능. cf: Any는 value type
                                                    // 즉 가리키는 포인터가 동일한지 체크
      self.presentImagePickerController()
      return false
    }
    return true
  }
  
  //⭐️⭐️⭐️shouldSelect가 true를 반환한 뒤에 화면이 정상적으로 바뀌었을 떄 호출되는 녀석
  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    
  }
}


extension MainTabBarController: UIImagePickerControllerDelegate {
  
  //이미시 선택했을 때
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //print(info) //정보들이 넘어옴
    //info : ["UIImagePickerControllerMediaType": public.image, "UIImagePickerControllerReferenceURL": assets-library://asset/asset.JPG?id=9F983DBA-EC35-42B8-8773-B597CF782EDD&ext=JPG, "UIImagePickerControllerOriginalImage": <UIImage: 0x600000287210> size {3000, 2002} orientation 0 scale 1.000000]
    //⭐️⭐️⭐️ dictionary에서 꺼내오는 값은 항상 optional!!!!!
    guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
    print(selectedImage)  //breakPoint찍어서 selectedImage 잘 넘어오는지 확인! 하단에 눈모양을 누르면 quick look이 가능함 - UIImage인 경우
                          //⭐️⭐️imageView 만들어서 이미지 띄워서 잘 나오는지 안나오는지 확인 안해도됨!!!
    //⭐️⭐️⭐️ 디버깅 도중 일시정지 누른 뒤에 debug view hierarchy 선택하면 3d로 view의 모습 볼 수 있다!!
    guard let grayscaledImage = selectedImage.grayscaled() else { return }
    print(grayscaledImage)
    
    
    //⭐️이제 이 선택한 이미지를 cropVC에 전달하자!! - init에 전달할것!!
    let cropViewController = CropViewController(image: grayscaledImage)
    //push로 화면 전환. imagepickerController는 자체적으로 navigatioController 지원
    
    //⭐️⭐️CropViewController에서 이미지 수정이 완료되었다는 것을 캐치해서 포스트작성VC 로 넘겨줌
    cropViewController.didFinishCropping = { image in
      // TODO: 포스트 작성 화면 띄우기
      self.presentPostEditorViewController(image: image, from: picker)
    }
    
    picker.pushViewController(cropViewController, animated: true)
  }
  
  //cancel 눌렀을 떄
  
}

extension MainTabBarController: UINavigationControllerDelegate {}
