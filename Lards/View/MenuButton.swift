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
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      sharedInit()
   }
   
   required init?(coder: NSCoder) {
      super.init(coder: coder)
      sharedInit()
   }
   
   override func draw(_ rect: CGRect) {
      layer.backgroundColor = self.tintColor.cgColor
   }

   func sharedInit() {
      layer.cornerRadius = const.cornerRadius
      self.contentEdgeInsets = const.edgeInsets
      self.setTitle(self.titleLabel?.text?.uppercased(), for: .normal)
      self.setTitleColor(const.textColor, for: .normal)
      self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
   }

}
