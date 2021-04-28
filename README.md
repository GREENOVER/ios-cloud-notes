# iOS Cloud Notes Application Project
### 클라우드 서버와 동기화 할 수 있는 메모 기능을 구현한 동기화 메모장 앱 프로젝트
[Ground Rule](https://github.com/GREENOVER/ios-cloud-notes/blob/main/GroundRule.md)
***
#### What I learned✍️
- JSON
- ListView
- Localization
- SwiftyDropbox
- CoreData
- Alamofire
- Size Class
- Compact & Regular Size
- searchBar
- EndEditing & DidEndEditing
- SplitView
- UserDefault
- Activity View
- SPM (Swift Package Manager)

#### What have I done🧑🏻‍💻
- 뷰를 전부 코드로 구현해보고 오토레이아웃을 적용하였다. 
    - 충돌을 일으키지 않게 스토리보드 파일 삭제
- 언어와 날짜에 대한 지역화를 구현하였다.
- 코어데이터를 학습하고 싱글턴으로 구현하여 로컬에 앱의 메모 데이터를 저장하도록 구현하였다.
- 드롭박스 외부 라이브러리에 대해 학습하고 사용하여 클라우드와 동기화할 수 있도록 고민하였다.
- Alamofire을 통한 서버 통신에 대해 학습하였다.
- 기기의 컴팩트 및 레귤러 사이즈에 대한 Size Class에 따라 각 뷰가 알맞게 보이도록 구현하였다.
- 마크주석을 적극적으로 활용하여 긴 파일의 코드의 가시성을 높였다.
- 서치바를 이용해 해당 메모를 찾도록 구현하였다.
- 가로모드 시 스플릿 뷰로 구현하여 아이패드 메모장처럼 나타나도록 구현하였다.
- 코어 데이터 모델 및 CRUD를 설계하고 구현하였다.
- 유저 디폴트를 정의하여 선택된 셀의 인덱스를 저장하도록 구현하였다.
- 디코드에 대한 테스트 메서드를 구현하여 mock data로 테스트를 진행하였다.
- 의존성 관리도구에 대해 학습하고 팀원과 협의하여 SPM으로 채택하고 진행하였다.




#### Trouble Shooting👨‍🔧
- 문제점 (1)
  - Supporting 파일들을 폴더화 시켜 이동한 후 앱을 빌드할 시 컴파일 오류가 나는 문제가 발생
- 원인
  - info.plist의 위치가 변경되어 찾을 수 없다는 에러 메시지를 토대로 프로젝트 설정에서 info.plist 파일의 위치가 잘못되어 발생하였다.
- 해결방안
  - 아래와 같이 타겟 빌드 세팅에서 info.plist.File 파일 위치를 해당 그룹화한 폴더 아래로 변경해주어 해결하였다.
  <img width="768" alt="스크린샷 2021-04-28 오후 1 20 12" src="https://user-images.githubusercontent.com/72292617/116346084-775ffb00-a824-11eb-8b9b-94f0ca9a1317.png">
- 문제점 (2)
  - Compact 사이즈로 뷰를 로드하면 아래와 같이 메모리스트가 나타난 뷰가 아닌 메모의 내용이 담긴 컨텐츠뷰가 나타나는 문제가 발생
  <img width="641" alt="스크린샷 2021-04-28 오후 1 41 01" src="https://user-images.githubusercontent.com/72292617/116347556-606ed800-a827-11eb-9151-12d59797336f.png">
- 원인
  - 스플릿뷰에서 뷰컨트롤러 배열의 마지막 요소 화면을 첫 화면으로 띄워주는것같다.
- 해결방안
  - 처음에는 UISplitViewDelegate로 로드 화면을 설정해줬는데 만약 textView가 선택된 상황에서 기기 사이즈를 Regular -> Compact로 전환하면 textView가 아닌 tableView가 보여졌다. 이에 SplitViewController의 뷰 생명주기를 활용해 viewDidLoad시 테이블뷰를 추가, viewDidAppear시 textView를 추가해주는 방향으로 설정하였다. 또한, tableView에서 셀이 선택되지 않았을때와 선택되었을때를 구분하기위해 firstSelection이라는 Bool 타입 프로퍼티를 추가해 true일때 UISplitViewDelegate 방식으로 화면이 전환되도록 구현하였다.
- 문제점 (3)
  - 위 문제점2에서 파생된 문제로 NavigaionBar의 BackButton 코드를 추가해 셀이 선택되었는지 제어하려했으나 잘되지 않는 문제 발생
- 원인
  - 메모장 화면에서 viewDisapper을 호출할때 값을 제어해줄 수 없어 발생
- 해결방안
  - isCellSelected: Bool값을 제어할 수 있도록 초기에는 아래와 같이 Notification을 활용하여 해당 값을 관리하였다.
  ```swift
  NotificationCenter.default.addObserver(self, selector: #selector(changeIsCellSelected), name: NSNotification.Name("ShowTableView"), object: nil)
  ```
  그 후 발전시켜 노티피케이션보다 UserDefault에 값을 저장하고 사용하는것이 더 효율적일것 같아 수정하였다.
  ```swift
  UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isCellSelected.rawValue)
  ```
  이 후 메모를 삭제하거나 생성의 기능을 할때에도 해당 유저디폴트의 키값을 이용하니 더 편리하게 구현이 가능해졌다.
- 문제점 (4)
  - 텍스트를 편집하지 않을때에도 네비게이션의 완료 버튼이 나타나는 문제 발생
- 원인
  - 네비게이션 바 아이템에 완료 버튼을 미리 추가하여 텍스트 수정이 시작되지 않아도 해당 자리에 나타나게된다.
- 해결방안
  - 스택뷰로 완료 버튼을 isHidden처리를 해주는 방법과 텍스트 편집 시에 해당 완료 버튼을 추가해주는 방법이 있었는데 후자를 택해 구현하였다.
  ```swift
  // MARK: UITextViewDelegate
  extension MemoContentsViewController {
        textView.textStorage.attribute(NSAttributedString.Key.link, at: glyphIndex, effectiveRange: nil) == nil {
        placeCursor(textView, tappedLocation)
        makeTextViewEditable()
        navigationItem.rightBarButtonItems?.insert(finishButton, at: 0)
      }
  }
  ```
- 문제점 (5)
  - 네비게이션 바 버튼의 액션이 제대로 동작하지 않는 문제 발생
  ```swift
     let disclosureButton = UIButton()
  // private let disclosureButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(showActionSheet))
  ```
  위와 같이 UIButton으로 구성하면되는데 UIBarButtonItem으로 구성하면 액션동작이 되지 않는 문제가 발생하였다.
- 원인
  - VC 초기화 관련문제였다. UIBarButtonItem을 초기화하는 시점이 네비게이션 바 버튼이 만들어지기전에 동작하여 액션 동작이 제대로 되지 않았다.
- 아ㄹ
  - VC 초기화 관련문제였다. UIBarButtonItem을 초기화하는 시점이 네비게이션 바 버튼이 만들어지기전에 동작하여 액션 동작이 제대로 되지 않았ㅎ
  - VC 초기화 관련문제였다. UIBarButtonItem을 초기화하는 시점이 네비게이션 바 버튼이 만들어지기전에 동작하여 액션 동작이 제대로 되지 않았다.


#### Thinking Point🤔
- 고민점 (1)
  - "UITextView, dataDetectorTypes & isEditable"
  ```swift
  @objc func textViewDidTapped(_ recognizer: UITapGestureRecognizer) {
      if "UIDataDetectorTypes을 터치했을때" == nil {
          return
      } else if let textView = recognizer.view as? UITextView {
          var location = recognizer.location(in: textView)
          location.x -= textView.textContainerInset.left
          location.y -= textView.textContainerInset.top
          
          placeCursor(textView, location)
          makeTextViewEditable()
      }
  }
  ```
  dateDetectorTypes를 터치했을때 기본적으로 구현된 방식으로(URL이면 사파리를 열고, 전화번호면 메세지를 열고..) 동작하고 다른 곳 터치 시 터치 지점에서 편집 가능하도록 커서 코드를 작성하려고 했는데 해당 터치 시 조건에 어떤 코드가 들어와야 원하는 기능 동작을 할 수 있을까?
- 원인 및 대책
  - sholdInteractWith deleate를 활용해봤는데 원하는 기능을 수행해주지 않았다. 이에 기존 코드를 아래와 같이 재구현하여 스크린 터치 시 그 위치를 CGPoint로 알아내 다음 동작을 구분하는 조건문으로 변경하였다.
  ```swift
  @objc func textViewDidTapped(_ recognizer: UITapGestureRecognizer) {
        if memoTextView.isEditable { return }
        
        guard let textView = recognizer.view as? UITextView else {
            return
        }
        let tappedLocation = recognizer.location(in: textView)
        let glyphIndex = textView.layoutManager.glyphIndex(for: tappedLocation, in: textView.textContainer)
        
        if glyphIndex < textView.textStorage.length,
           textView.textStorage.attribute(NSAttributedString.Key.link, at: glyphIndex, effectiveRange: nil) == nil {
            placeCursor(textView, tappedLocation)
            makeTextViewEditable()
            
            navigationItem.rightBarButtonItems?.insert(finishButton, at: 0)
        }
        
        if glyphIndex >= textView.textStorage.length {
            makeTextViewEditable()
        }
    }
    
    private func placeCursor(_ myTextView: UITextView, _ location: CGPoint) {
        if let tapPosition = myTextView.closestPosition(to: location) {
            let uiTextRange = myTextView.textRange(from: tapPosition, to: tapPosition)
            
            if let start = uiTextRange?.start, let end = uiTextRange?.end {
                let loc = myTextView.offset(from: myTextView.beginningOfDocument, to: tapPosition)
                let length = myTextView.offset(from: start, to: end)
                myTextView.selectedRange = NSMakeRange(loc, length)
            }
        }
    }
  ```
- 고민점 (3)
  - "문서화 주석을 활용하여 메서드가 어떤 동작을 하는지 표시해줄 수 없을까?"
  ```swift
  import Foundation

  extension Date {
    func toStringWithDot() -> String {
  ...
  ```
- 원인 및 대책
  - 확장한 기능들에 대해 아래와 같이 문서화 주석을 활용하였으며 또한 메서드 별 어떤 기능을 하는지 //MARK: 주석을 활용하였다.
  ```swift
  import Foundation

  extension Date {
    /// Returns string converted from data with user's current locale.
  ...
  ```
- 고민점 (4)
  - "쓰지 않는 메서드는 삭제하는 편이 좋을까?"
  ```swift
  window = UIWindow(windowScene: windowScene)
  window?.rootViewController = MemoSplitViewController()
  window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
  ...
  ```
- 원인 및 대책
  - SceneDelegate / AppDelegate에 사용하지 않는 메서드들도 초기에 자동으로 함께 생성된다. 성능상의 이점보다는 우선 사용하지 않는 부분을 걷어내는것이 가독성과 유지보수에 용이하기에 삭제하였다. (개발중 사용한 불필요한 주석도 걷어내는것이 좋다.)
- 고민점 (5)
  - "실패하는 케이스들에 대해 만들어보는것은 어떨까?"
  ```swift
  XCTAssertEqual(memoList[0].title, "똘기떵이호치새초미자축인묘")
  XCTAssertEqual(memoList[3].title, "네번째")
  // 실패할 테스트
  ...
  ```
- 원인 및 대책
  - 실패하는 케이스도 만드는것이 TDD의 핵심으로 실패 케이스에 대해 추가하였다.
  ```swift
  XCTAssertEqual(memoList[0].title, "똘기떵이호치새초미자축인묘")
  XCTAssertEqual(memoList[3].title, "네번째")
  // 실패할 테스트
  XCTAssertEqual(memoList[3].lastModified, 202020, "It would fail")
  ```




#### InApp📱
![InApp_1](https://user-images.githubusercontent.com/72292617/116345618-74183f80-a823-11eb-95bc-8416a8a7f536.gif)   

![InApp_2](https://user-images.githubusercontent.com/72292617/116345828-dcffb780-a823-11eb-8887-45087d08ce5f.gif)
