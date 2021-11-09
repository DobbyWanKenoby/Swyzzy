import UIKit

/// Координатор сцены создается на уровне SceneDelegate и управляет работой сцены, передачей данных и общими ресурсами на уровне сцены.
///
/// В режиме работы с несколькими сценами (например на iPad) у каждой из них будет свой SceneCoordinator.
/// Рекомендуется использовать данный координатор для управления на уровне сцены.
open class SceneCoordinator: BasePresenter, Transmitter {
    public var edit: ((Signal) -> Signal)?
    
    // ссылка на окно, в котором отображается интерфейс
    public var window: UIWindow!
    
    // при изменении значения
    open override var presenter: UIViewController? {
        didSet {
            window.rootViewController = presenter
            window.makeKeyAndVisible()
        }
    }
    
    public convenience init(appCoordinator: AppCoordinator, window: UIWindow, options: [CoordinatorOption] = []) {
        self.init(presenter: nil, rootCoordinator: appCoordinator, options: options)
        self.window = window
    }
    
}
