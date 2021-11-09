
//
// Координаторы и вью контроллеры могут быть Ресиверами (Receiver)
// Ресиверы принимают и обрабатывают получаемые данные (сигналы, Signal)
//
// Обычно ресивер обрабатывает только тот тип данных, который он поддерживает
// Если сигналы представляют из себя перечисления, подписанные на протокол Signal,
// то для этого в методе receive необходимо использовать следующую конструкцию:
//
// if case SomeSignalEnumeration.enumerationElement(let receivedValue) { ... }
//
// - SomeSignalEnumeration: перечисление, подписанное на протокол Signal
// - enumerationElement: элемент перечисления
// - receivedValue: ассоциированный параметр
//


/// Координатор-ресивер может обрабатывать принимаемые сигналы
public protocol Receiver {
    @discardableResult
    func receive(signal: Signal) -> Signal?
}

extension Receiver {
   public func receive(signal: Signal) -> Signal? {
        return nil
    }
}
