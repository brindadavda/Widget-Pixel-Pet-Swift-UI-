//
//  UIImage+Extensions.swift
//  Tamagochi
//
//  Created by Systems
//

import SwiftUI

typealias UIImage_TamagochiVVV = UIImage

extension UIImage_TamagochiVVV {
    
    var topHalf: UIImage? {
        cgImage?.cropping(
            to: CGRect(
                origin: .zero,
                size: CGSize(width: size.width, height: size.height / 2)
            )
        )?.image
    }
    
    var bottomHalf: UIImage? {
        cgImage?.cropping(
            to: CGRect(
                origin: CGPoint(x: .zero, y: size.height - (size.height/2).rounded()),
                size: CGSize(width: size.width, height: size.height - (size.height/2).rounded())
            )
        )?.image
    }
    
    var leftHalf: UIImage? {
        cgImage?.cropping(
            to: CGRect(
                origin: .zero,
                size: CGSize(width: size.width/2, height: size.height)
            )
        )?.image
    }
    
    var rightHalf: UIImage? {
        cgImage?.cropping(
            to: CGRect(
                origin: CGPoint(x: size.width - (size.width/2).rounded(), y: .zero),
                size: CGSize(width: size.width - (size.width/2).rounded(), height: size.height)
            )
        )?.image
    }
    
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
      let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
      let format = imageRendererFormat
      format.opaque = isOpaque
      return UIGraphicsImageRenderer(size: canvas, format: format).image {
        _ in draw(in: CGRect(origin: .zero, size: canvas))
      }
    }
    
}

typealias CGImage_TamagochiVVV = CGImage

extension CGImage_TamagochiVVV {
    
    var image: UIImage { .init(cgImage: self) }
    
}
