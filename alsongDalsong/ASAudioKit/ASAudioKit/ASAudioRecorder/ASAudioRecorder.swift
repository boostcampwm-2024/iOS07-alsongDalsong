import AVFoundation

public actor ASAudioRecorder {
    private var audioRecorder: AVAudioRecorder?

    public init() {}
    /// 녹음 후 저장될 파일의 위치를 지정하여 녹음합니다.
    public func startRecording(url: URL) {
        configureAudioSession()
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            // TODO: AVAudioRecorder 객체 생성 실패 시에 대한 처리
        }
    }

    /// 오디오 세션을 설정합니다.
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            // TODO: 세션 설정 실패에 따른 처리
        }
    }

    /// 녹음 진행 여부를 확인합니다.
    public func isRecording() -> Bool {
        if let audioRecorder {
            return audioRecorder.isRecording
        }
        return false
    }

    /// 녹음을 중단합니다. 녹음된 파일을 리턴합니다.
    @discardableResult
    public func stopRecording() -> Data? {
        // 녹음 종료 시에 어디 저장되었는지 리턴해줄 필요가 있을 듯, 저장된 녹음파일을 network에 던져줄 필요가 있음.
        audioRecorder?.stop()

        guard let recordURL = audioRecorder?.url else { return nil }

        do {
            let recordData = try Data(contentsOf: recordURL)
            return recordData
        } catch {
            return nil
        }
    }

    /// 현재 녹음된 시간을 리턴합니다.
    public func getCurrentTime() -> TimeInterval {
        return audioRecorder?.currentTime ?? 0
    }

    /// recorder의 입력 레벨을 업데이트합니다.
    public func updateMeters() {
        audioRecorder?.updateMeters()
    }

    /// recorder에 입력된 평균 dB을 리턴합니다.
    public func getAveragePower() -> Float? {
        return audioRecorder?.averagePower(forChannel: 0)
    }
}
