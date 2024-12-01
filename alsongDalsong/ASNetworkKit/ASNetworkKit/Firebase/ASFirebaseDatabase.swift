import ASEntity
import ASLogKit
import Combine
@preconcurrency internal import FirebaseFirestore

public final class ASFirebaseDatabase: ASFirebaseDatabaseProtocol {
    private let firestoreRef = Firestore.firestore()
    private var roomListeners: ListenerRegistration?
    private var roomPublisher = CurrentValueSubject<Room?, Error>(nil)
    
    public func addRoomListener(roomNumber: String) -> AnyPublisher<Room, Error> {
        let roomRef = firestoreRef.collection("rooms").document(roomNumber)
        let listener = roomRef.addSnapshotListener { documentSnapshot, error in
            if let error {
                return self.roomPublisher.send(completion: .failure(error))
            }
            
            guard let document = documentSnapshot, document.exists else {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors.FirebaseListenerError))
            }
            
           if document.metadata.isFromCache {
               Logger.debug("로컬 캐시에서 데이터를 가져온 경우")
               return
           }
            
            do {
                let room = try document.data(as: Room.self)
                Logger.debug("방 정보를 가져왔습니다.\n\(room)")
                return self.roomPublisher.send(room)
            } catch {
                return self.roomPublisher.send(completion: .failure(ASNetworkErrors.FirebaseListenerError))
            }
        }
        
        roomListeners = listener
        return roomPublisher
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    public func removeRoomListener() {
        roomPublisher.send(nil)
        roomListeners?.remove()
    }
}
