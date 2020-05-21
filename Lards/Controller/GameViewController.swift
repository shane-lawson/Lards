//
//  GameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

   // MARK: Injected Properties
   
   var game: LardGame!
   
   // MARK: IBOutlets
   
   @IBOutlet weak var deckView: PlayingCardView!

   override func viewDidLoad() {
      super.viewDidLoad()

      deckView.rank = .two
      deckView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deckTapped)))
   }

   @objc func deckTapped() {
      print("Deck tapped")
   }

   /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
   }
   */

}
