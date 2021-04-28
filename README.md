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



#### Thinking Point🤔





#### InApp📱
![InApp_1](https://user-images.githubusercontent.com/72292617/116345618-74183f80-a823-11eb-95bc-8416a8a7f536.gif)
![InApp_2](https://user-images.githubusercontent.com/72292617/116345828-dcffb780-a823-11eb-8887-45087d08ce5f.gif)
