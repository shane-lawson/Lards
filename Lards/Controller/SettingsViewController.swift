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
   
   override func viewDidLoad() {
      super.viewDidLoad()


      colorSwatch.layer.cornerRadius = 5.0
//      colorSwatch.layer.borderWidth = 1.0
//      colorSwatch.layer.borderColor = UIColor.systemGray.cgColor
      setColors()
      colorSwatch.isUserInteractionEnabled = false
      
      nameTextField.delegate = self
      nameTextField.placeholder = LardsUserDefaults.displayName
   }
    
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setColors()
   }
   
   func setColors() {
      let color = UIApplication.shared.windows.first?.tintColor ?? LardsUserDefaults.tintColor
      colorSwatch.backgroundColor = color
      switches.forEach { $0.onTintColor = color }
   }
   
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
