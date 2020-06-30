//
//  NewGameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class NewGameViewController: UIViewController {

   // MARK: Properties
   
   let game = LGLardGame()
   
   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }

   // MARK: IBActions
   
   @IBAction func joinGameTapped(_ sender: UIButton) {
      performSegue(withIdentifier: "joinGame", sender: self)
   }
   
   @IBAction func createGameTapped(_ sender: UIButton) {
      performSegue(withIdentifier: "createGame", sender: self)
   }
   
   // MARK: - Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      switch segue.identifier {
      case "createGame":
         if let loadingVC = segue.destination as? CreatingGameViewController {
            loadingVC.game = game
         }
      case "joinGame":
         if let loadingVC = segue.destination as? JoiningGameViewController {
            loadingVC.game = game
         }
      default:
         break
      }
   }

}
