import Combine
import Foundation

@propertyWrapper
public class PublishedValue<Value: Equatable> {
    private let subject: CurrentValueSubject<Value, Never>
    
    public var projectedValue: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public var wrappedValue: Value {
        didSet {
            if wrappedValue != oldValue {
                subject.send(wrappedValue)
            }
        }
    }
    
    public init(wrappedValue: Value) {
        self.subject = CurrentValueSubject<Value, Never>(wrappedValue)
        self.wrappedValue = wrappedValue
    }
}
