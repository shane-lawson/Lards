//
//  MenuButton.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class MenuButton: UIButton {
   typealias const = ViewConstants.MenuButton
   
   override func draw(_ rect: CGRect) {
      layer.cornerRadius = const.cornerRadius
      layer.borderColor = const.borderColor
      layer.borderWidth = const.borderWidth
      self.contentEdgeInsets = const.edgeInsets
      self.titleLabel?.text = self.titleLabel?.text?.uppercased()
//      layer.shadowOpacity = 1.0
//      layer.shadowColor = const.shadowColor
//      layer.shadowOffset = const.shadowOffset
   }

}
