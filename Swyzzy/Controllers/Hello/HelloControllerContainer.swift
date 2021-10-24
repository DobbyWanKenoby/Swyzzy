//
//  HelloControllerContainer.swift
//  Swyzzy
//
//  Created by Vasily Usov on 24.10.2021.
//

import Foundation
import UIKit

protocol HelloControllerContainerProtocol: UIViewController {
	/// Процесс приветствия завершен
	var helloProcessDidEnd: (() -> Void)? { get set }
}

final class HelloControllerContainer: UIViewController, HelloControllerContainerProtocol {

	var helloProcessDidEnd: (() -> Void)?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .red
	}
	
}
