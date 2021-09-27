//
//  FirebaseCoordinator.swift
//  Swyzzy
//
//  Created by Vasily Usov on 20.09.2021.
//

import Foundation
import SwiftCoordinatorsKit
import Firebase

protocol FirebaseCoordinatorProtocol: BaseCoordinator, Transmitter {}

class FirebaseCoordinator: BaseCoordinator, FirebaseCoordinatorProtocol {
    var edit: ((Signal) -> Signal)?
    
    override func startFlow(withWork work: (() -> Void)? = nil, finishCompletion: (() -> Void)? = nil) {
        super.startFlow(withWork: work, finishCompletion: finishCompletion)
        // конфигурирование Firebase
        FirebaseApp.configure()
        
    }
}
