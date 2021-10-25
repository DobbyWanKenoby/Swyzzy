import UIKit
import SnapKit

/*
 Контроллер, отображаемый в ходе работы InitializationCoordinator
 Предназначен для того, чтобы визуально отображать процесс инициализации приложения
 Чтобы в процессе загрузки необходимых данных не весел пустой экран
 
 На нем можно выводить анимированный SplashScreen, индикатор загрузки и т.д.
 */

protocol InitializationControllerProtocol where Self: UIViewController {
	// тип отображения
	var displayType: [InitializationControllerDisplayType] { get set }
	// работа, которую необходимо выполнить после появления экрана инициализации
	// тут необходимо указать влю логику загрузки данных
	var startInitializationWork: (()->Void)? { get set }
	// старт финальной анимации и работа, которую необходимо после этого выполнить
	// тут необходимо прописать экран, к которому будет происходить переход далее
	func stopInitialization(withWork : (()->Void)?)
}

// Тип отображеняи контроллера
enum InitializationControllerDisplayType {
	// с индикатором загрузки
	case withActivityIndicator
	// с анимацией названия (укзжает вверх)
	case withLogoAnimationTop
}

class InitializationController: UIViewController, InitializationControllerProtocol {
	var displayType: [InitializationControllerDisplayType] = []
	var startInitializationWork: (()->Void)?

	lazy private var logoImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "Title"))
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	lazy private var loadingIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .large)
		view.tintColor = .red
		return view
	}()

	override func loadView() {
		super.loadView()
		view.addSubview(logoImageView)
		logoImageView.snp.makeConstraints { make in
			make.leftMargin.rightMargin.equalTo(42)
			make.center.equalToSuperview()
		}

		self.view.addSubview(loadingIndicator)
		loadingIndicator.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.bottom.equalToSuperview().offset(-50)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		if displayType.contains(.withActivityIndicator) {
			loadingIndicator.startAnimating()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		startInitializationWork?()
	}

	func stopInitialization(withWork work: (()->Void)?) {
		if displayType.contains(.withActivityIndicator) {
			UIView.animate(withDuration: 0.3) {
				self.loadingIndicator.alpha = 0
			}
		}

		if displayType.contains(.withLogoAnimationTop) {
			logoImageView.snp.removeConstraints()
			logoImageView.snp.updateConstraints { make in
				make.width.equalTo(UIScreen.main.bounds.width - 180)
				make.top.equalTo(130)
				make.trailing.equalTo(-90)
			}
		}

		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		} completion: { _ in
			work?()
		}
	}
}
