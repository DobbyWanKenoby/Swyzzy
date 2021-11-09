import UIKit

/// Базовый координатор содержит базовую функциональность.
///
/// Рекоменудется наследовать собственные координаторы от данного.
open class BaseCoordinator: Coordinator {
    open var options: [CoordinatorOption] = []
    open var rootCoordinator: Coordinator? = nil
    open var childCoordinators: [Coordinator] = []
    open var finishCompletion: (() -> Void)? = nil
    
    @discardableResult
    public init(rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        self.options = options
        if let rootCoordinator = rootCoordinator {
            self.rootCoordinator = rootCoordinator
            self.rootCoordinator?.childCoordinators.append(self)
        }
    }
    
    open func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        self.finishCompletion = finishCompletion
        work?()
    }

}
