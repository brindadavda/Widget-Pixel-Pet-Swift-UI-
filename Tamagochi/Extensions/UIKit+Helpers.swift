//
//  UIKit+Helpers.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

struct BackgroundClearView: UIViewRepresentable {
    
    private class TransparentView: UIView {
        override func layoutSubviews() {
            super.layoutSubviews()
            superview?.superview?.backgroundColor = .clear
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        return TransparentView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
         
    }
}

struct StatusBarTabDetector: UIViewRepresentable {

    var onTap: () -> ()

    func makeUIView(context: Context) -> UIView {
        let fakeScrollView = UIScrollView()
        fakeScrollView.backgroundColor = .green
        fakeScrollView.contentOffset = CGPoint(x: 0, y: 10)
        fakeScrollView.delegate = context.coordinator
        fakeScrollView.scrollsToTop = true
        fakeScrollView.contentSize = CGSize(width: 100, height: UIScreen.main.bounds.height * 2)
        return fakeScrollView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
         
    }

    func makeCoordinator() -> Coordinator_TamagochiVVV {
        
         
        
        return Coordinator_TamagochiVVV(onTap: onTap)
    }

    class Coordinator_TamagochiVVV: NSObject, UIScrollViewDelegate {

        var onTap: () -> ()

        init(onTap: @escaping () -> ()) {
            self.onTap = onTap
        }

        func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            onTap()
            return false
        }
    }
    
}
