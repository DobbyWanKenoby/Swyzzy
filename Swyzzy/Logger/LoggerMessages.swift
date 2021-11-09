//
//  LoggerMessages.swift
//  Swyzzy
//
//  Created by Vasily Usov on 09.11.2021.
//

import Foundation

enum LoggerMessage: String {

    // ---
    // Coordinators
    // ---
    case coordinatorStartedFlow = "Coordinator started own flow"
    case coordinatorFinishedFlow = "Coordinator finished own flow"

    // ---
    // Route
    // ---
    case routeViewController = "Route to new View Controller"

    // ---
    // Firebase
    // ---

    // Синхронизация данных о пользователе
    case userDocumentCreated = "User's document created in Firestore"
    case userDocumentNotCreated = "User's document didn't create in Firestore"
    case userDataDidDownload = "User's data downloaded from Firestore"
    case userDataDontDownload = "User's data didn't download from Firestore"

}
