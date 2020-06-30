//
//  ColorPickerViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/28/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
   // MARK: IBOutlets
   
   @IBOutlet weak var pickerView: UIPickerView!
   @IBOutlet weak var navBar: UINavigationItem!
   
   // MARK: Properties
   
   let colors: [UIColor] = [
      .systemBlue,
      .systemGreen,
      .systemIndigo,
      .systemOrange,
      .systemPink,
      .systemPurple,
      .systemRed,
      .systemTeal,
      .systemYellow,
      .systemGray,
      .systemGray2,
      .systemGray3,
      .systemGray4
   ]
   
   var globalColor: UIColor {
      get{
         return UIApplication.shared.windows.first?.tintColor ?? LardsUserDefaults.tintColor
      }
      set(newColor){
         UIApplication.shared.windows.first?.tintColor = newColor
         LardsUserDefaults.tintColor = newColor
      }
   }
   
   lazy var selectedColor: UIColor = globalColor
   
   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      view.frame.size.height = 300
      
      navBar.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
      navBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
      
      pickerView.delegate = self
      pickerView.dataSource = self
      pickerView.selectRow(colors.firstIndex{$0 == globalColor}!, inComponent: 0, animated: false)
   }
   
   // MARK: BarButton Actions
   
   @objc func cancel() {
      dismiss(animated: true, completion: nil)
   }
   
   @objc func done() {
      globalColor = selectedColor
      performSegue(withIdentifier: "backToSettings", sender: nil)
   }
   
   // MARK: - UIPickerViewDelegate
   
   func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
      return 100
   }
   
   func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
      let button = UIButton()
      button.isUserInteractionEnabled = false
      button.backgroundColor = colors[row]
      button.frame.size = CGSize(width: self.view.frame.width, height: self.pickerView.rowSize(forComponent: component).height)
      return button
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      let color = colors[row]
      view.tintColor = color
      selectedColor = color
   }
   
   // MARK: - UIPickerViewDataSource

   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return colors.count
   }
   
}
