import Foundation
import Combine
import ASRepository
import ASAudioKit
import ASEntity

final class HummingResultViewModel: @unchecked Sendable {
    private var hummingResultRepository: HummingResultRepositoryProtocol
    private var avatarRepository: AvatarRepositoryProtocol
    private var gameStatusRepository: GameStatusRepositoryProtocol
    private var playerRepository: PlayersRepositoryProtocol
    private var roomActionRepository: RoomActionRepositoryProtocol
    private var roomInfoRepository: RoomInfoRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isNext: Bool = false
    @Published var currentResult: Answer?
    @Published var currentRecords: [ASEntity.Record] = []
    @Published var currentsubmit: Answer?
    @Published var recordOrder: UInt8? = 0
    @Published var isHost: Bool = false
    
    // 미리 받아놓을 정보 배열
    private var recordsResult: [ASEntity.Record] = []
    private var submitsResult: Answer?
    private var roomNumber: String = ""
    
    var hummingResult: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)] = []
    
    init(hummingResultRepository: HummingResultRepositoryProtocol,
         avatarRepository: AvatarRepositoryProtocol,
         gameStatusRepository: GameStatusRepositoryProtocol,
         playerRepository: PlayersRepositoryProtocol,
         roomActionRepository: RoomActionRepositoryProtocol,
         roomInfoRepository: RoomInfoRepositoryProtocol) {
        self.hummingResultRepository = hummingResultRepository
        self.avatarRepository = avatarRepository
        self.gameStatusRepository = gameStatusRepository
        self.playerRepository = playerRepository
        self.roomActionRepository = roomActionRepository
        self.roomInfoRepository = roomInfoRepository
        fetchResult()
    }
    
    // TODO: 함수 명이 바뀔 필요가 있는 듯함.
    private func fetchResult() {
        hummingResultRepository.getResult()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                //TODO: 성공 실패 여부에 따른 처리
                print(completion)
            } receiveValue: { [weak self] (result: [(answer: ASEntity.Answer, records: [ASEntity.Record], submit: ASEntity.Answer)]) in
                self?.hummingResult = result.sorted {
                    $0.answer.player?.order ?? 0 < $1.answer.player?.order ?? 1
                }
                guard let current = self?.hummingResult.removeFirst() else { return }
                self?.currentResult = current.answer
                self?.recordsResult = current.records
                self?.submitsResult = current.submit
            }
            .store(in: &cancellables)
        
        playerRepository.isHost()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isHost in
                self?.isHost = isHost
            }
            .store(in: &cancellables)
        
        roomInfoRepository.getRoomNumber()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] roomNumber in
                self?.roomNumber = roomNumber
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(gameStatusRepository.getStatus(), gameStatusRepository.getRecordOrder())
            .receive(on: DispatchQueue.main)
            .sink { status, order in
                if (status == .result) && (self.recordOrder ?? 0 + 1 == order) {
                    self.isNext = true
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func startPlaying() {
        Task {
            while !recordsResult.isEmpty {
                currentRecords.append(recordsResult.removeFirst())
                guard let fileUrl = currentRecords.last?.fileUrl else { continue }
                do {
                    let data = try await fetchRecordData(url: fileUrl)
                    await AudioHelper.shared.startPlaying(file: data)
                    await waitForPlaybackToFinish()
                } catch {
                    print("녹음 파일 다운로드에 실패하였습니다.")
                }
            }
            currentsubmit = submitsResult
        }
    }
    
    private func waitForPlaybackToFinish() async {
        await withCheckedContinuation { continuation in
            Task {
                while await AudioHelper.shared.isPlaying() {
                    // 재생이 끝날 때까지 대기
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
                }
                continuation.resume()
            }
        }
    }
    
    func nextResultFetch() {
        let current = self.hummingResult.removeFirst()
        
        self.currentResult = current.answer
        self.recordsResult = current.records
        self.submitsResult = current.submit
        self.currentRecords.removeAll()
        self.currentsubmit = nil
    }
    
    private func getRecordData(url: URL?) -> AnyPublisher<Data?, Error> {
        if let url {
            return hummingResultRepository.getRecordData(url: url)
                .eraseToAnyPublisher()
        }else {
            return Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    private func fetchRecordData(url: URL) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            getRecordData(url: url)
                .compactMap { $0 }
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                }, receiveValue: { data in
                    continuation.resume(returning: data)
                })
                .store(in: &cancellables)
        }
    }
    
    func getAvatarData(url: URL?) -> AnyPublisher<Data?, Error> {
        if let url {
            avatarRepository.getAvatarData(url: url)
                .eraseToAnyPublisher()
        } else {
            Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func changeRecordOrder() {
        Task {
            do {
                try await self.roomActionRepository.changeRecordOrder(roomNumber: roomNumber)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
