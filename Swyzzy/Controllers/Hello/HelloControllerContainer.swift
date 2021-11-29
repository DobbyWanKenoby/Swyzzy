import UIKit
import SnapKit

protocol HelloControllerContainerProtocol: UIViewController {
	/// Процесс приветствия завершен
	var helloProcessDidEnd: (() -> Void)? { get set }
}

final class HelloControllerContainer: UIViewController, HelloControllerContainerProtocol {

	var helloProcessDidEnd: (() -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()
        initSetup()
	}
    
    private func initSetup() {
        view.backgroundColor = .white
    }
}
