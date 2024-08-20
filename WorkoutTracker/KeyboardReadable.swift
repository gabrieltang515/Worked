//
//  KeyboardReadable.swift
//  WorkoutTracker
//
//  Created by Gabriel Tang on 30/7/24.
//

//import Foundation
//import UIKit
//import Combine
//
//protocol KeyboardReadable {
//    var keyboardPublisher: AnyPublisher<Bool, Never> {get}
//}
//
//
//extension KeyboardReadable {
//    var keyboardPublisher: AnyPublisher<Bool, Never> {
//        Publishers.Merge(
//            NotificationCenter.default
//                .publisher(for: UIResponder.keyboardWillShowNotification)
//                .map { _ in true },
//            
//            NotificationCenter.default
//                .publisher(for: UIResponder.keyboardWillHideNotification)
//                .map { _ in false }
//        )
//        .eraseToAnyPublisher()
//    }
//}
