import ASEntity

public protocol ASFirebaseDatabaseProtocol {
    // MARK: 특정 RoomId 변경이 생겼을 경우 이벤트를 등록하는 함수.
    func addRoomListener(roomId: String, completion: @escaping (Result<ASEntity.Room, Error>) -> Void)
    // MARK: 특정 RoomID 이벤트 등록을 해제하는 함수.
    func removeRoomListener(roomId: String)
}
