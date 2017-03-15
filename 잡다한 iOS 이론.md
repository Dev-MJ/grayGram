- 메서드나 property 앞에 /// 불라불라 쓰면 해당 녀석의 description에 그 불라불라가 들어감
  ​

- ViewController의 LifeCycle

  - viewdidload - vc가 메모리에 올라간 직후
  - viewwillappear - 
  - viewdidappear - 뜨는 애니메이션이 끝날 때
  - viewWilldisappear
  - viewdiddisappear - 사라지는 애니메이션이 끝날 때
    ​

- then을 사용하면 초기화와 함께 속성 지정 가능(devxoul library)

  ```swift
  let label = UILabel().then {
       $0.textAlignment = .center
       $0.textColor = .black
       $.text = "hello, world"
  }
  ```

- cancel과 같은 위험한 로직은 사용자로부터 confirm을 받는 로직이 필요

  - 사용자가 잘못된 액션을 했을 때 피드백을 주는 로직도 필요
    ​

- 클로져 사용시에는 현재 화면에서만 반영.

  - noti이용하면 모든 뷰에 반영 시킬 수 있음
    -  global한(앱에서 코드로 접근할 수 있는 모든 범위) center가 있음. 이center에 noti를 하면, 이 center를 observing하고있는 녀석이 그것을 받음
      ​

- notificationcenter는 기본적으로 싱글톤 인스턴스를 제공

  ​

- addobserver를 하면 remove해야함

  - VC가 메모리에서 제거될 때 observer남아있으면 에러냄



- notification 주의

  - 컴파일러가 잡지 못함.
    -  swift 3.0부터 name을 .~~처럼 정적으로 쓸 수 있음
    -  userinfo는 그렇지 못하므로 문서화 잘해야함

  ​

- guard let 의 return은 반복문에서는 break로 해도 됨

  ​

- lazy

  ```swift
  let arr = [1,2,3,4,5,3,3,3,3,3]
  arr
      .filter { $0 ==3 }    //6개인 배열이 생성됨.
      .first    

  arr
      .lazy
      .filter {$0 ==3 }    
      .first     //실제 값을 꺼내오는 순간에 

  변수 앞 lazy
      //처음 그 변수가 호출 될 때 인자에 값이 할당됨.
  func veryveryveryveryHeavyfunction() -> String {
      return "hi"
  }

  class Dog {
      var name: String = veryveryveryveryHeavyfunction()
      
  }

  let dog = Dog()    //이 순간에 veryveryverveyrHeavyfunction()    실행
  dog.name //lazy 붙이면  dog.name 이 순간에 실행

  ```

  ​

- bounds vs frame

  - bounds : x,y = 0인 frame



- cancel : 내가 하려던거 계속 (왼쪽)



- localization
  - Resources -> new file -> strings File 생성 -> Localizable.strings -> 우측 Localize 선택 -> English 선택 ->    타겟 말고 project -> info -> localizations -> + -> Korean 선택 -> 새로 만든 strings파일만 체크 -> strings파일이 언어별로 나뉘어있음 -> 각 언어별 파일마다 key, value 설정
  - base : string파일이 아니고 스토리보드 파일에서 사용



- -v : --verbose = 진행과정 보여주는 옵션



- cocoaPods
  - Podfile 만들어야함
    1. 루비문법
    2. target : 프로젝트의 타겟. 타겟별로 의존성 라이브러리 설치
    3. ~> 3.0  : 3.0 이상 4.0 미만. 즉 가장 하위 소수점만 움직임
    4. 3.0 : 3.0만 찾음
  - use_frameworks!
    1. swift : dynamic framework 방식을 사용
    2. objc : static framework 사용.
    3. 이 두개를 구분해 주기 위해 cocoapods에서 사용하는 것
  - pod ‘Alamofire’, ‘~> 4.3’
    1. pod(‘Alamofire’, ‘~> 4.3’)이라는 함수를 실행시키는 건데, 루비는 () 없이 실행 가능



- main.storyboard 삭제 -> target -> General -> Main interface 공백 -> Appdelegate이동 -> UIWindow생성 -> UIWindow의 rootViewController 설정



- 시뮬레이터에서 debug - color blended layers 하면 view별로 색 다르게 구분할 수 있음



- **computed property : 메모리에 할당되지 않음**

  ​

- extension에도 where절 부여 가능.