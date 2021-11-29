//
// Экран, отображающий некоторую информацию в формате
// - Картинка
// - Заголовок
// - Текст

import Foundation
import UIKit

protocol HelloInformationScreen: UIViewController {

    /// Сделать при нажатии на кнопку
    var actionOnPressButton: (() -> Void)? { get set }
    /// Конфигурация экрана в соответствии с указанными значениями
    func configureWith(image: UIImage?, title: String, text: String, buttonText: String)

}

class HelloInformationController: UIViewController, HelloInformationScreen {
    var actionOnPressButton: (() -> Void)?

    func configureWith(image: UIImage?, title: String, text: String, buttonText: String) {
        imageView.image = image
        titleText.text = title
        descriptionText.text = text
        exitButton.setTitle(buttonText, for: .normal)
    }

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, titleText, descriptionText])
        stack.distribution = .fill
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        return stack
    }()

    lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var titleText: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .bold)
        return label
    }()

    lazy var descriptionText: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .light)
        return label
    }()

    lazy var exitButton: SWButton = {
        let button = SWButton()
        button.addAction(UIAction(handler: { _ in
            self.actionOnPressButton?()
        }), for: .touchUpInside)
        return button
    }()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .white

        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.topMargin.equalTo(100)
            make.leadingMargin.trailingMargin.equalTo(40)
        }

        imageView.snp.makeConstraints { make in
            let aspectRation = 1.5
            let baseSize = UIScreen.main.bounds.width - 80
            make.width.equalTo(baseSize)
            make.height.equalTo(baseSize / aspectRation)
        }

        view.addSubview(exitButton)
        exitButton.snp.makeConstraints { make in
            make.bottomMargin.equalTo(-40)
            make.centerX.equalToSuperview()
            make.trailingMargin.leadingMargin.equalTo(40)
            make.height.equalTo(50)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
}
