
<div align="center">
  
## 알쏭달쏭 🎶
  
|📚 바로가기|[팀 Notion](https://mature-browser-f84.notion.site/12ee7c2fd62b80c196a2eef239b0b884?pvs=4)|[팀 Wiki](https://github.com/boostcampwm-2024/iOS07-alsongDalsong/wiki)|[팀 Figma](https://www.figma.com/design/Pv9SVfpYLjeRE00yMT4OF1/%EA%B0%88%ED%8B%B1%ED%8F%B0?node-id=0-1&t=eTWR2a895ooGgznA-1)|[팀 그라운드 룰](https://github.com/boostcampwm-2024/iOS07-boostproject/wiki/%EA%B7%B8%EB%9D%BC%EC%9A%B4%EB%93%9C-%EB%A3%B0)|[팀 협업 룰](https://mature-browser-f84.notion.site/12de7c2fd62b8077bd98da954a08c472?pvs=4)|
|:-:|:-:|:-:|:-:|:-:|:-:|
<img width=300 src="https://github.com/user-attachments/assets/ccbffd92-b2a7-495c-9681-23d5280281f2">

### **🎧 귀를 쫑긋 세우세요 ! 🎧** 

여러분을 음악과 다양한 소리가 넘치는 세계로 안내합니다. 

친구들과 함께 노래를 듣고, 부르며 다양한 게임을 즐겨보세요 ! 

허밍모드, 하모니 모드, 이구동성 모드, 1초 듣고 맞추기 모드 등 여러가지 모드가 준비되어있어요 ! 

순서에 따라 변형되는 허밍을 듣고 녹음하며 원래 노래가 무엇이었는지 맞춰보세요 ! 

**알쏭달쏭의 세계로 떠나보세요 ! 🎶** 
</div>

|<img width=300 src="https://github.com/user-attachments/assets/5d6e9355-7738-4361-92cd-824ad6d6b470"> | <img width=300 src="https://github.com/user-attachments/assets/a12d8c07-2e50-460c-b5b1-e686e00a3cf2">| <img width=300 src="https://github.com/user-attachments/assets/41b05c64-06e6-4559-8cf1-4d302f1e4ad5">|
|:-:|:-:|:-:|
<div align="center">
  
## Team 대대대대(DDDD)
|S024 박상원|S029 박진성|S033 손승재|S050 이민하|
|:-:|:-:|:-:|:-:|
|<img src="https://github.com/user-attachments/assets/1ea87e89-64d3-4948-8ae7-40b03802af01" width=150>|<img src="https://github.com/user-attachments/assets/5bc994cc-d56d-472f-b91d-4e545e42bf51" width=150>|<img src="https://github.com/user-attachments/assets/35077735-1bf3-46e5-b086-da1f7f17510b" width=150>|<img src="https://github.com/user-attachments/assets/c7d1b9c7-1b5e-44f8-ba8f-ba6258a8a5fe" width=150>|
|[@psangwon62](https://github.com/psangwon62)|[@Tltlbo](https://github.com/kth1210)|[@Sonny-Kor](https://github.com/Sonny-Kor)|[@moral-life](https://github.com/moral-life)|
|로얄 iOS핑|물 흘러가듯이<br>살고 있습니도르.|나는 더 나은<br>미래를 위해 싸운다|도덕적인 삶을 추구하는<br>개발자 이민하입니다.|
|대구|대구|대구|대전|

</div>



## 기술 스택

### MusicKit

- 먼저 FirstParty 프레임워크를 위주로 사용해보기 위해 Spotify API가 아닌 해당 프레임워크를 채택하였습니다.
- 애플 사용자에 한해 MusicKit은 사용에 있어 인증 과정이 복잡하지 않고 간단히 구현할 수 있기에 채택하게 되었습니다.
- 프로젝트에서 사용되는 음악에 대한 정보를 사용하기 위해서 사용됩니다.

### AVFoundation

- AVAudioRecoder
    - 사용자가 녹음하는 기능을 제공하기 위함.
- AVAudioPlayer
    - 녹음된 파일이나 MusicKit에서 제공된 음악 파일을 출력하기 위해 사용됩니다.
- AVAudioEngine
    - 녹음된 파일에 오디오 처리와 효과를 적용하여 출력하기 위해 사용됩니다.
- Speech Synthesis (TTS)
    - 가사 읽기 모드에서 시리 TTS를 통해 가사를 시리 목소리로 출력하기 위해 사용됩니다.

### UIKit + SwiftUI

- SwiftUI는 UI를 구현하기에는 용이하나, SwiftUI만으로 구현하지 못하는 부분이 존재하기 때문에 UIKit을 기반으로 프로젝트를 구성했습니다.
- 애니메이션 구현에 있어 SwiftUI가 주는 이점도 존재하기에 간단한 뷰나 SwiftUI의 Animation이 필요한 부분에 부분 도입할 예정입니다.

<br>

<div align="center">


</div>
