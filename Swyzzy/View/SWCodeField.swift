//
//  SWCodeTextField.swift
//  Swyzzy
//
//  Created by Vasily Usov on 10.10.2021.
//

import UIKit
import Swinject

final class SWCodeField: UIStackView {
    
    // Когда код введен во все поля
    var onCodeEntered: (() -> Void)?
    
    private var enteredCode: [Int] {
        var resultNumbers = [Int]()
        textFields.forEach { textField in
            if let text = textField.text, let number = Int(text) {
                resultNumbers.append(number)
            }
        }
        return resultNumbers
    }
    
    private var textFields: [UITextField] = []
    
    private lazy var bottomLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 4))
        backgroundColor = .gray
        view.layer.cornerRadius = 3
        view.clipsToBounds = false
        return view
    }()
    
    convenience init() {
        self.init(frame: .zero)
        
        // два дочерних стека с текстовыми полями
        self.addArrangedSubview(getBlockStackView())
        self.addArrangedSubview(getBlockStackView())
        
        for subStackView in arrangedSubviews {
            for _ in 1...3 {
                
                // текстовое поле
                let textField = getTextField()
                textFields.append(textField)

                // stack для объединения поля и линии
                let stackView = UIStackView(arrangedSubviews: [textField, getBottomLine()])
                stackView.distribution = .fill
                stackView.axis = .vertical
                stackView.spacing = 2

                (subStackView as? UIStackView)?.addArrangedSubview(stackView)
            }
        }
        
        self.axis = .horizontal
        self.spacing = 20
        self.distribution = .fillEqually
    }
    
    // Внутренний StackView, объединяющий текстовое поле и линию под ним
    private func getBlockStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }
    
    // Текстовое поле, в которое вводится число
    private func getTextField() -> UITextField {
        let textField = SWCodeTextField()
        // обработчик нажатия на кнопку удаления символа
        textField.onDeleteBackward = {
            self.removeLastNumber()
            let lastFieldIndex = self.enteredCode.count
            self.textFields[lastFieldIndex].becomeFirstResponder()
        }
        textField.keyboardType = .numberPad
        textField.addAction(getActionFor(textField: textField), for: .editingChanged)
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 30)
        textField.delegate = self
        return textField
    }
    
    private func getActionFor(textField: UITextField) -> UIAction {
        let action = UIAction { action in
            guard let text = textField.text, let _ = Int(text) else {
                return
            }
            let lastFieldIndex = self.enteredCode.count
            if lastFieldIndex < self.textFields.count && lastFieldIndex > 0  {
                self.textFields[lastFieldIndex].becomeFirstResponder()
            } else {
                self.textFields.last?.resignFirstResponder()
                self.onCodeEntered?()
            }
        }
        return action
    }
    
    // Линия под текстовым полем
    private func getBottomLine() -> UIView {
        let view = UIView()
        view.snp.makeConstraints { make in
            make.height.equalTo(3)
        }
        view.backgroundColor = UIColor(named: "UnderLineColor")
        view.layer.cornerRadius = 3
        return view
    }
    
    // MARK: Helpers
    
    // Удаляет символ из последнего заполненного текстового поля
    private func removeLastNumber() {
        for textField in textFields.reversed() {
            if let text = textField.text, text != "" {
                textField.text =  ""
                return
            }
        }
    }
    
    // Активирует первое незаполненное текстовое поле
    // В случае, когда заполнены все поля, то активирует последнее
    private func activateCorrectTextField() {
        let lastFieldIndex = self.enteredCode.count
        if lastFieldIndex == textFields.count {
            self.textFields.last?.becomeFirstResponder()
        } else if lastFieldIndex == 0 {
            self.textFields.first?.becomeFirstResponder()
        } else {
            self.textFields[lastFieldIndex].becomeFirstResponder()
        }
    }

}

extension SWCodeField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activateCorrectTextField()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Если текст вставляется, например из пришедшей СМС
        if string.count > 1 {
            // TODO: Добавить обработку вставки текста
            return true
        // Если текст вводится
        } else {
            // Ограничение на количество вводимых символов
            let maxLength = 1
            let currentString: NSString = (textField.text ?? "") as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
    }
    
}

// Кастомный класс текстового поля с переопределенным поведением по нажатию на бэкспейс
final class SWCodeTextField: UITextField {
    
    var onDeleteBackward: (() -> Void)?
    
    override public func deleteBackward() {
        onDeleteBackward?()
        super.deleteBackward()
    }
}
