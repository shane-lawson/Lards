//
//  MainMenuViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      navigationController?.setNavigationBarHidden(true, animated: true)
   }

   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.setNavigationBarHidden(false, animated: true)
   }
 
   // MARK: IBActions
   
   @IBAction func iconAttributionTapped(_ sender: UIButton) {
      UIApplication.shared.open(URL(string: "https://game-icons.net/1x1/lorc/poker-hand.html")!)
   }
   
   @IBAction func backToMainMenu(_ segue: UIStoryboardSegue) {
      // nothing
   }
}
