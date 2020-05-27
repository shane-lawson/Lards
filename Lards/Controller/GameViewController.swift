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
   @IBOutlet weak var myCard: PlayingCardView!
   @IBOutlet weak var theirCard: PlayingCardView!
   
   var deckCenter: CGPoint!
   var newCoords1: CGPoint!
   
   override func viewDidLoad() {
      super.viewDidLoad()

      myCard.rank = .none
      theirCard.rank = .none
      
      deckView.rank = .nine
      deckView.suit = .hearts
      deckView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deckTapped)))
      deckCenter = deckView.center
      
      game.subscribeToNotifications(of: [.refreshedLocation], observer: self, selector: #selector(updateWeatherOnCards))
   }

   @objc func deckTapped() {
//      let newCard = PlayingCardView()
//      newCard.rank = .two
//      newCard.suit = .clubs
//      view.addSubview(newCard)
//      view.bringSubviewToFront(newCard)
//      newCard.center = deckCenter
      
//      myCard.superview.remove
      
//      UIViewPropertyAnimator.runningPropertyAnimator(
//         withDuration: 0.5,
//         delay: 0,
//         options: [.curveEaseInOut],
//         animations: {
//            self.deckView.center = self.myCard.center
//
//         },
//         completion: { (animatingPosition) in
//            self.myCard = self.deckView
//            self.deckView.center = self.deckCenter
//      })
      newCoords1 = self.myCard.superview!.convert(self.myCard.center, to: self.view)
      self.deckView.move(to: newCoords1, duration: 1, options: [.curveEaseInOut])
      UIView.transition(
         with: self.deckView,
         duration: 0.5,
         options: [.transitionFlipFromLeft],
         animations: {
            self.deckView.isFaceUp = !self.deckView.isFaceUp
      },
         completion: nil)

   }
   
   @objc func updateWeatherOnCards() {
      PlayingCardView.weather = game.weather
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
