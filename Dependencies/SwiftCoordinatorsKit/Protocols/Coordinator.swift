/// Базовый протокол, которому должен соответствовать любой координатор
public protocol Coordinator: AnyObject {
    /// Настройки координатора
    var options: [CoordinatorOption] { get }
    /// Замыкание, которое должно быть выполнено по завершению потока (в методе finishFlow)
    var finishCompletion: (() -> Void)? { get set }
    /// Ссылка на родительский координатор
    var rootCoordinator: Coordinator? { get set }
    /// Ссылки на дочерние координаторы
    var childCoordinators: [Coordinator] { get set }
    /// Старт выполнения потока координатора
    /// - Parameters:
    ///    - withWork: работа, которая должна быть выполнена в процессе старта выполнения потока координатора
    ///    - finishCompletion: работа, которая должна быть выполнена в процессе завершения работы координатора. Например, вы можете отключить неиспользуемые ресурсы и т.д.
    func startFlow(withWork: (() -> Void)?, finishCompletion: (() -> Void)?)
    /// Завершение потока координатора.
    ///
    /// При этом должно быть выполнено замыкание, переданное в `startFlow` в параметре `finishCompletion`. Помимо этого дополнительно может быть передана некоторые инструкции, требующие выполнения. При завершении выполнения потока данный метод вызывается для всех дочерних координаторов
    /// - Parameters:
    ///    - withWork: работа, которая должна быть выполнена в процессе завершения выполнения потока координатора
    func finishFlow(withWork: (() -> Void)?)
}

extension Coordinator {
    
    public func startFlow(withWork work: (() -> Void)?, finishCompletion: (() -> Void)? = nil) {
        // сохраняем замыкание, которое должно быть выполнено в конце потока
        self.finishCompletion = finishCompletion
        // выполняем переданные инструкции
        work?()
    }
    
    public func finishFlow(withWork work: (() -> Void)? = nil) {
        work?()
        self.finishCompletion?()
        // если у координатор есть родитель, то удаляем совместные ссылки
        if let rootCoordinator = rootCoordinator  {
            for (index, child) in rootCoordinator.childCoordinators.enumerated() {
                if child === self {
                    rootCoordinator.childCoordinators.remove(at: index)
                    child.rootCoordinator = nil
                }
            }
        }
        childCoordinators.forEach { (coordinator) in
            coordinator.finishFlow(withWork: nil)
        }
    }
    
}

/// Настройки координатора
public enum CoordinatorOption {
    
    /// Общий координатор.
    ///
    /// Данный параметр проверяется при передаче данных Трансмиттерами (`Transmitter`). В случае, если координатора является общим (`shared`), то сигналы (`Signal`) передаются в него, даже если передающий Трансмиттер находится в изолированном режиме (см. настройку `isolateMode`)
    case shared

    /// Изолированный режим
    /// 
    /// При использовании данного режима сигналы (`Signal`) передаются в родительский координатора, в дочерние-shared координаторы (`.shared`) и в дочерние контроллеры. В дочерние НЕ общие координаторы сигналы не передаются.
    ///
    /// С помощью данной настройки получается эффект, когда ветки дочерних координаторов не взаимодействуют межуд собой. То есть полученный от дочернего координатора сигнал не передается в другие дочерние координаторы (если они не являются общими).
    case isolateMode

    // Режим Транк
    // сигналы передаются только в указанные координаторы
    //case trunkMode(toCoordinators: [Coordinator], andControllers: [UIViewController])
}
