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
   
   var game: LGLardGame!
   
   // MARK: IBOutlets
   
   @IBOutlet weak var deckView: PlayingCardView!
   @IBOutlet weak var myCard: PlayingCardView!
   @IBOutlet weak var theirCard: PlayingCardView!
   
   var deckCenter: CGPoint!
   var newCoords1: CGPoint!
   
   let haptic = UIImpactFeedbackGenerator(style: .light)
   
   override func viewDidLoad() {
      super.viewDidLoad()

      myCard.isHidden = true
      theirCard.isHidden = true
      
      let deck = LGPlayingCardDeck()
      deck.shuffle()
      
      let card = deck.cards.popLast()!

      deckView.rank = card.rank
      deckView.suit = card.suit
      deckView.willGetWeather = game.isLocationEnabled
      deckView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deckTapped)))
      deckCenter = deckView.center
      
      if game.isLocationEnabled {
         game.subscribeToNotifications(of: [.refreshedLocation, .receivedCardPlayed], observer: self, selector: #selector(handleNotifications(_:)))
      }
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
      game.play(LGPlayingCard(deckView.rank, deckView.suit))
      
      newCoords1 = self.myCard.superview!.convert(self.myCard.center, to: self.view)
      self.deckView.move(to: newCoords1, duration: 1, options: [.curveEaseInOut], completion: {_ in self.haptic.impactOccurred()})
      UIView.transition(
         with: self.deckView,
         duration: 0.5,
         options: [.transitionFlipFromLeft],
         animations: {
            self.deckView.isFaceUp = !self.deckView.isFaceUp
      },
         completion: nil)

   }
   
   @objc func handleNotifications(_ notification: Notification) {
      typealias type = LGLardGame.NotificationType
      DispatchQueue.main.async {
         switch notification.name {
         case type.refreshedLocation.name:
            PlayingCardView.weather = self.game.weather
            self.deckView.stopAnimatingWeatherIcon()
         case type.receivedCardPlayed.name:
            if let info = notification.userInfo {
               let player = info["player"] as! LGPlayer
               let card = info["card"] as! LGPlayingCard
               self.theirCard.rank = card.rank
               self.theirCard.suit = card.suit
               self.theirCard.isFaceUp = true
               self.theirCard.isHidden = false
            }
            
         default:
            print("Received notification which is unhandled in GameViewController")
         }
      }
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
