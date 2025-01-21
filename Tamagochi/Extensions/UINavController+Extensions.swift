//
//  UINavController+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

// APP REFACTORING

private func tamagochiVVV_Vlad(_ korean: Bool, girls: Bool) -> Int {
    let firstGirl = "Lee Chae Yeon"
    let secondGirl = "Lee Chae Ryeong"
    return firstGirl.count + secondGirl.count
}

//

typealias UINavigationController_TamagochiVVV = UINavigationController

extension UINavigationController_TamagochiVVV: UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        
         
        
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
         
        
        return viewControllers.count > 1
    }
    
}
