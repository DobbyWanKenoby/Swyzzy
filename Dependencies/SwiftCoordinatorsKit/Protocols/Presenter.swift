import UIKit

/// Координатор-презентор отвечает за отображение сцен на экране и переход между ними
public protocol Presenter where Self: Coordinator {
    /// Ссылки на дочерние контроллеры
    ///
    /// Данное свойство используется, когда в свойстве `presenter` хранится контейнерный контроллер и необходимо хранить ссылки на дочерние
    var childControllers: [UIViewController] { get set }
    /// Главный коонтроллер данного координатора
    var presenter: UIViewController? { get set }
    /// Осуществленеи перехода к новой сцене (новому вью контроллеру)
    ///
    /// - Parameters:
    ///     - from: Контроллер, с которого проиcходит переход
    ///     - to: Контроллер, к которому происходит переход
    ///     - method: Тип перехода
    ///     - completion: Обработчик завершения перехода
    func route(from: UIViewController, to: UIViewController, method: RouteMethod, completion: (() -> Void)?)
    /// Осуществление выхода с экрана
    ///
    /// - Parameters:
    ///     - controller: Контроллер, с которого проиcходит переход
    ///     - method: Тип перехода
    ///     - completion: Обработчик завершения перехода
    func disroute(controller: UIViewController, method: DisrouteMethod, completion: (() -> Void)?)
}

extension Presenter {
    public func route(from sourceController: UIViewController, to destinationController: UIViewController, method: RouteMethod, completion: (() -> Void)? = nil) {
        switch method {
        case .custom(let transitionDelegate):
            destinationController.transitioningDelegate = transitionDelegate
            destinationController.modalPresentationStyle = .custom
            sourceController.present(destinationController, animated: true, completion: completion)
        case .presentFullScreen:
            sourceController.transitioningDelegate = nil
            destinationController.modalPresentationStyle = .fullScreen
            destinationController.modalTransitionStyle = .coverVertical
            sourceController.present(destinationController, animated: true, completion: completion)
        case .presentCard:
            sourceController.transitioningDelegate = nil
            sourceController.modalPresentationStyle = .none
            sourceController.modalTransitionStyle = .coverVertical
            sourceController.present(destinationController, animated: true, completion: completion)
        case .navigationPush:
            (sourceController as! UINavigationController).pushViewController(destinationController, animated: true)
            completion?()
        }
    }
    
    public func disroute(controller: UIViewController, method: DisrouteMethod, completion: (() -> Void)? = nil) {
        switch method {
        
        case .dismiss:
            controller.dismiss(animated: true, completion: completion)
        case .navigationPop:
            (controller as! UINavigationController).popViewController(animated: true)
            completion?()
        }
    }
}

// MARK: TransitionDelegate

/// Данный протокол используется в случае, когда необходимо отобразить сцену с помощью метода `Presenter.route` используя кастомный `Transition Delegate`
public protocol SCKTransitionDelegate: UIViewControllerTransitioningDelegate {
    init(transitionData: TransitionData?)
}

extension SCKTransitionDelegate {
    public init(transitionData: TransitionData? = nil) {
        fatalError("This initializator can not used in \(Self.self) type")
    }
}

/// Данные для `UIViewControllerTransitioningDelegate`, обеспечивающие кастомный переход
///
/// Тут могут находиться произвольные данные, которые необходимо передать в `UIViewControllerTransitioningDelegate`
public protocol TransitionData {}

/// Типы перехода между вью контроллерами
public enum RouteMethod {
    /// Показать сцену в качестве карточки
    case presentCard
    /// Показать сцену на веь экран
    case presentFullScreen
    /// Добавить сцену в Navigation Stack.
    ///
    /// Для использования данного элемента отображение контроллера, с которого происходит переход должен быть UINavigationController
    case navigationPush
    /// Совершить кастомный переход
    ///
    /// Для использования данного элемента необходимо реализовать класс, подписанный на протоколы UIViewControllerTransitioningDelegate & SCKTransitionDelegate
    case custom(SCKTransitionDelegate)
}

/// Типы обратного перехода (выхода) с вью контроллера
public enum DisrouteMethod {
    /// Обычнео скрытие контроллера
    case dismiss
    /// Переход на 1 элемент назад в Navigation Stack
    case navigationPop
}
