import Foundation
import Testing

struct ASAudioPlayerTests {
    var player: ASAudioPlayer?
    var testMusic: Data?

    init() async throws {
        player = ASAudioPlayer()
        if let url = Bundle.main.url(forResource: "PlayTestDrum", withExtension: "wav") {
            do {
                testMusic = try Data(contentsOf: url)
            } catch {
                #expect(false)
            }
        }
    }

    @Test func sta$rtPlaying_성공() async throws {
        guard let player,
              let testMusic else
        {
            #expect(false)
            return
        }

        player.startPlaying(data: testMusic, option: .full)

        #expect(player.isPlaying())
    }

    @Test func 제한된시간동안startPlaying_성공() async throws {
        guard let player,
              let testMusic else
        {
            #expect(false)
            return
        }

        player.startPlaying(data: testMusic, option: .partial(time: 6))

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            #expect(player.getCurrentTime() == 6)
            #expect(player.isPlaying() == false)
        }

        // swiftTesting에서 XCTest에서 비동기 테스트에 사용되는 expectation을 대체할 방법을 못찾겠음
        // + 기존 XCTAssertEqual에서 오차값을 설정할 수 있었는데 그런게 보이지 않음.
        #expect(player.isPlaying())
    }
}
