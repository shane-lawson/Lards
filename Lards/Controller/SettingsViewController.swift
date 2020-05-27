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
   
   override func viewDidLoad() {
      super.viewDidLoad()

      nameTextField.delegate = self
      nameTextField.placeholder = LardsUserDefaults.displayName
   }
    
   @IBAction func updateName(_ sender: UIButton) {
      LardsUserDefaults.displayName = nameTextField.text!
      nameTextField.placeholder = nameTextField.text!
      nameTextField.text = nil
      nameTextField.resignFirstResponder()
      updateButton.isEnabled = false
   }
   
   @IBAction func toggleGestures(_ sender: UISwitch) {
      LardsUserDefaults.gestures = sender.isOn
   }
   
   @IBAction func toggleHaptics(_ sender: UISwitch) {
      LardsUserDefaults.haptics = sender.isOn
   }
   
   /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
   }
   */
   
   // MARK: - UITextFieldDelegate

   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      updateButton.isEnabled = textField.text!.count > 2
      return true
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField.text!.count > 2 {
         updateName(updateButton)
         return true
      } else {
         return false 
      }
   }
}
