public protocol Registerable {
    func register<T>(_ type: T.Type, factory: @escaping (Resolvable) -> T)
    func register<T>(_ type: T.Type, _ object: T)
}

public protocol Resolvable {
    func resolve<T>(_ type: T.Type) -> T
}

public protocol Assembly {
    func assemble(container: Registerable)
}

public final class DIContainer: Registerable, Resolvable {

    
    
    nonisolated(unsafe) static let shared = DIContainer()
    private init() {}
    
    private var factories = [String: (Resolvable) -> Any]()
    
    public func register<T>(_ type: T.Type, factory: @escaping (Resolvable) -> T) {
        let key = "\(type)"
        factories[key] = factory
    }
    
    public func register<T>(_ type: T.Type, _ object: T) {
        let key = "\(type)"
        factories[key] = { _ in object }
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let key = "\(type)"
        
        guard let dependency = factories[key] as? T else {
            fatalError("등록되지 않은 의존성 타입: \(type)")
        }
        
        return dependency
    }
    
    public func addAssemblies(_ assemblies: [Assembly]) {
        assemblies.forEach { $0.assemble(container: self) }
    }
}
