import Foundation
import Testing

struct ASAudioRecorderTests {
    var recorder: ASAudioRecorder?

    init() async throws {
        recorder = ASAudioRecorder()
    }

    @Test func startRecording_성공() async throws {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("녹음성공테스트")
        guard let recorder else {
            #expect(false)
            return
        }
        recorder.startRecording(url: url)
        #expect(recorder.isRecording())
    }

    @Test func stopRecording_성공() async throws {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("녹음저장성공테스트")
        guard let recorder else {
            #expect(false)
            return
        }
        recorder.startRecording(url: url)
        recorder.stopRecording()
        #expect(FileManager.default.fileExists(atPath: url.path))
    }
}
