protocol Assembly {
    func assemble(container: DIContainer)
}

public final class DIContainer {
    nonisolated(unsafe) static let shared = DIContainer()
    private init() {}
    
    private var factories = [String: () -> Any]()
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = "\(type)"
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = "\(type)"
        
        guard let dependency = factories[key] as? T else {
            fatalError("등록되지 않은 의존성 타입: \(type)")
        }
        
        return dependency
    }
    
    func addAssemblies(_ assemblies: [Assembly]) {
        assemblies.forEach { $0.assemble(container: self) }
    }
}
