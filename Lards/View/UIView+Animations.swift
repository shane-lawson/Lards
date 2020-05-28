//
//  UIView+Animations.swift
//  Lards
//
//  Created by Shane Lawson on 5/22/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
   func move(to endPoint: CGPoint, duration: TimeInterval, options: UIView.AnimationOptions, completion: ((Bool) -> Void)? = nil) {
      UIView.animate(
         withDuration: duration,
         delay: 0,
         options: options,
         animations: {
            self.center = endPoint
      }, completion: completion)
   }
   
//   func flip(to endPoint: CGPoint = self.frame.center, duration: TimeInterval, options: UIView.AnimationOptions) {
//      UIView.an
//   }
}
