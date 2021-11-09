import UIKit

/// Координатор приложения создается на уровне AppDelegate и управляет работой приложения, общими ресурсами и передачей данных на уровне приложения в целом.
///
/// Рекомендуется использовать данный координатор для управления на уровне приложения.
open class AppCoordinator: BaseCoordinator, Transmitter {
    public var edit: ((Signal) -> Signal)?
    
    public required init(options: [CoordinatorOption] = []) {
        super.init(rootCoordinator: nil, options: options)
    }
    
    @discardableResult
    public override init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        if rootCoordinator != nil {
            fatalError("init(rootCoordinator:options:) has not been implemented")
        }
        super.init(rootCoordinator: nil, options: options)
    }
    
}
