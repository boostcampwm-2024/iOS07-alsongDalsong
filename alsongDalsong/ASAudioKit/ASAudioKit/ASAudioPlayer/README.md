#  ASAudioPlayer

ASAudioPlayer 객체 생성
```swift
let player = ASAudioPlayer()
```

재생 시작
```swift
let data: Data = ...
player.startPlaying(data: data, option: .full)
```

시간 재생 시작
```swift
player.startPlaying(data: data, option: .partial(6))
```

