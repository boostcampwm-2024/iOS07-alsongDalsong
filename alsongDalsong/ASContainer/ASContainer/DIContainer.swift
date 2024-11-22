public protocol Registerable {
    func register<T>(_ type: T.Type, factory: @escaping (Resolvable) -> T)
    func register<T>(_ type: T.Type, _ object: T)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping (Resolvable) -> T)
    func registerSingleton<T>(_ type: T.Type, _ object: T)
}

public protocol Resolvable {
    func resolve<T>(_ type: T.Type) -> T
}

public protocol Assembly {
    func assemble(container: Registerable)
}

public final class DIContainer: Registerable, Resolvable {
    @MainActor public static let shared = DIContainer()
    private init() {}
    
    private var factories = [String: (Resolvable) -> Any]()
    private var singletons = [String: Any]()
    
    public func register<T>(_ type: T.Type, factory: @escaping (Resolvable) -> T) {
        let key = "\(type)"
        factories[key] = factory
    }
    
    public func register<T>(_ type: T.Type, _ object: T) {
        let key = "\(type)"
        factories[key] = { _ in object }
    }
    
    public func registerSingleton<T>(_ type: T.Type, factory: @escaping (Resolvable) -> T) {
        let key = "\(type)"
        factories[key] = { [weak self] resolver in
            if let instance = self?.singletons[key] as? T {
                return instance
            } else {
                let instance = factory(resolver)
                self?.singletons[key] = instance
                return instance
            }
        }
    }
    
    public func registerSingleton<T>(_ type: T.Type, _ object: T) {
        let key = "\(type)"
        singletons[key] = object
    }
    
    public func resolve<T>(_ type: T.Type) -> T {
        let key = "\(type)"
        
        if let instance = singletons[key] as? T {
            return instance
        }
        
        guard let factory = factories[key] else {
            fatalError("등록되지 않은 의존성 타입: \(type)")
        }
        
        guard let dependency = factory(self) as? T else {
            fatalError("의존성 팩토리가 \(type) 타입의 인스턴스를 반환하지 않았습니다")
        }
        
        return dependency
    }
    
    public func addAssemblies(_ assemblies: [Assembly]) {
        assemblies.forEach { $0.assemble(container: self) }
    }
}
