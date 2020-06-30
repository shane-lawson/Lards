//
//  SettingsViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {

   // MARK: IBOutlets
   
   @IBOutlet weak var nameTextField: UITextField!
   @IBOutlet weak var updateButton: UIButton!
   @IBOutlet weak var colorSwatch: UIButton!
   @IBOutlet var switches: [UISwitch]!
   
   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()

      colorSwatch.layer.cornerRadius = 5.0
      setColors()
      colorSwatch.isUserInteractionEnabled = false
      
      nameTextField.delegate = self
      nameTextField.placeholder = LardsUserDefaults.displayName
   }
    
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setColors()
   }
   
   // MARK: UI Updates
   
   func setColors() {
      let color = UIApplication.shared.windows.first?.tintColor ?? LardsUserDefaults.tintColor
      colorSwatch.backgroundColor = color
      switches.forEach { $0.onTintColor = color }
   }
   
   // MARK: IBActions
   
   @IBAction func revertChooseColorSegue(_ segue: UIStoryboardSegue) {
      setColors()
   }
   
   @IBAction func updateName(_ sender: UIButton) {
      LardsUserDefaults.displayName = nameTextField.text!
      nameTextField.placeholder = nameTextField.text!
      nameTextField.text = nil
      nameTextField.resignFirstResponder()
      updateButton.isEnabled = false
   }
   
   @IBAction func toggleHaptics(_ sender: UISwitch) {
      LardsUserDefaults.haptics = sender.isOn
   }
   
   // MARK: - UITextFieldDelegate

   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      updateButton.isEnabled = textField.text!.count > 1
      return true
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField.text!.count > 1 {
         updateName(updateButton)
         return true
      } else {
         return false 
      }
   }
}
