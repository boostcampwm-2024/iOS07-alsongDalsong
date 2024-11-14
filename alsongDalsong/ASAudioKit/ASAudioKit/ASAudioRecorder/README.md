#  ASAudioRecorder

ASAudioRecorder 객체 생성
```swift
let recorder = ASAudioRecorder()
```

녹음 시작
```swift
let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
.appendingPathComponent("녹음성공테스트")
recorder.startRecording(url: url)
```

녹음 종료
```swift
recorder.stopRecording()
```
