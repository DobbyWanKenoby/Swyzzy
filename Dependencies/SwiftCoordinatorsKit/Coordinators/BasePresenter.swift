import UIKit

/// Базовый координатор-презентер содержит базовую функциональность Презентера.
///
/// Рекоменудется наследовать собственные координаторы от данного.
open class BasePresenter: BaseCoordinator, Presenter {
    open var childControllers: [UIViewController] = []
    open var presenter: UIViewController? = nil
    
    public init(presenter: UIViewController?, rootCoordinator: Coordinator? = nil, options: [CoordinatorOption] = []) {
        super.init(rootCoordinator: rootCoordinator, options: options)
        if let presenter = presenter {
            self.presenter = presenter
        }
    }
    
    @discardableResult
    public init(rootCoordinator: Coordinator? = nil) {
        super.init(rootCoordinator: rootCoordinator)
    }
}
