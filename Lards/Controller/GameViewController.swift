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
   
   @IBOutlet weak var SBdealDeckPlaceholder: PlayingCardView!
   @IBOutlet weak var SBopponentDeckPlaceholder: PlayingCardView!
   @IBOutlet weak var SBlocalPlayerDeckPlaceholder: PlayingCardView!
   @IBOutlet weak var SBopponentPlayedCardPlaceholder: PlayingCardView!
   @IBOutlet weak var SBlocalPlayerPlayedCardPlaceholder: PlayingCardView!
   @IBOutlet weak var SBopposingPlayerButton: UIButton!
   @IBOutlet weak var SBopponentCardCounterBottomCard: PlayingCardView!
   @IBOutlet weak var SBlocalPlayerCardCounterBottomCard: PlayingCardView!
   @IBOutlet weak var SBopponentCardCounterLabel: UILabel!
   @IBOutlet weak var SBlocalPlayerCardCounterLabel: UILabel!
   
   // MARK: Properties
   var opponentPlayedCard: PlayingCardView!
   var localPlayerPlayedCard: PlayingCardView!
   var tiedCards = [PlayingCardView]()
   
   let haptic = UIImpactFeedbackGenerator(style: .light)
   
   var localPlayerPlayedCardCenter: CGPoint {
      return view.convert(SBlocalPlayerPlayedCardPlaceholder.center, to: view)
   }
   
   var opponentPlayedCardCenter: CGPoint {
      return view.convert(SBopponentPlayedCardPlaceholder.center, to: view)
   }
   
   var localPlayerDeckCenter: CGPoint {
      return view.convert(SBlocalPlayerDeckPlaceholder.center, to: view)
   }
   
   var opponentDeckCenter: CGPoint {
      return view.convert(SBopponentDeckPlaceholder.center, to: view)
   }
   
   // MARK: Perform Segues
   
   @objc func backToMenu() {
      performSegue(withIdentifier: "backToMenu", sender: nil)
   }
   
   @objc func backToRejoin() {
      performSegue(withIdentifier: "backToRejoin", sender: nil)
   }
   
   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      if game.isLocationEnabled {
         game.subscribeToNotifications(of: [.refreshedLocation,.receivedCardPlayed, .dealingHand, .playResultReady, .endedGame, .playerDisconnected], observer: self, selector: #selector(handleNotifications(_:)))
      } else {
         game.subscribeToNotifications(of: [.receivedCardPlayed, .dealingHand, .playResultReady, .endedGame, .playerDisconnected], observer: self, selector: #selector(handleNotifications(_:)))
      }
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setupUI()
      updateCounters()
      NotificationCenter.default.addObserver(self, selector: #selector(backToRejoin), name: UIApplication.didEnterBackgroundNotification, object: nil)
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      game.unsubscribeFromNotifications(self)
      NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
   }
   
   // MARK: Helpers
   
   func tapHaptic() {
      if LardsUserDefaults.haptics {
         self.haptic.impactOccurred()
      }
   }
   
   func createCardView(card: PlayingCard? = nil, LGcard: LGPlayingCard? = nil, placeholder: UIView, faceUp isFaceUp: Bool = false) -> PlayingCardView {
      let cardView = PlayingCardView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: placeholder.frame.size))
      if let card = card {
         cardView.rank = card.rank
         cardView.suit = card.suit
      }
      if let card = LGcard {
         cardView.rank = card.rank
         cardView.suit = card.suit
      }
      cardView.isFaceUp = isFaceUp
      cardView.willGetWeather = game.isLocationEnabled
      cardView.refresh(game.weather)
      cardView.isOpaque = false
      view.addSubview(cardView)
      view.bringSubviewToFront(cardView)
      cardView.center = placeholder.center
      return cardView
   }
   
   // MARK: Play Card
   
   @objc func localPlayerDeckTapped() {
      SBlocalPlayerDeckPlaceholder.isUserInteractionEnabled = false
      
      //if game is quit while card is on table, have to pick the right one
      if let card = game.locallyPlayedCard {
         localPlayerPlayedCard = createCardView(LGcard: card, placeholder: SBlocalPlayerDeckPlaceholder)
      } else {
         let card = game.localPlayer.hand?.firstObject as! PlayingCard
         localPlayerPlayedCard = createCardView(card: card, placeholder: SBlocalPlayerDeckPlaceholder)
         game.play()
      }
      localPlayerPlayedCard.move(to: localPlayerPlayedCardCenter, completion: {_ in self.tapHaptic()})
   }
   
   // MARK: UI Updates
   
   func setupUI() {
      SBdealDeckPlaceholder.isHidden = true
      SBlocalPlayerPlayedCardPlaceholder.isHidden = true
      SBlocalPlayerDeckPlaceholder.isHidden = !game.isResumingGame
      SBopponentPlayedCardPlaceholder.isHidden = true
      SBopponentDeckPlaceholder.isHidden = !game.isResumingGame
      
      SBlocalPlayerDeckPlaceholder.willGetWeather = game.isLocationEnabled
      SBlocalPlayerDeckPlaceholder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(localPlayerDeckTapped)))
      SBopponentDeckPlaceholder.willGetWeather = game.isLocationEnabled

      let opposingPlayer = game.coreDataGame.players?.filter { player in
         let playerAsPlayer = player as! Player
         return playerAsPlayer != game.coreDataGame.localPlayer
      }.first! as! Player
      
      SBopposingPlayerButton.setTitle(opposingPlayer.displayName, for: .normal)
      
      SBlocalPlayerCardCounterBottomCard.transform = CGAffineTransform(rotationAngle: .pi/15)
      SBopponentCardCounterBottomCard.transform = CGAffineTransform(rotationAngle: .pi/15)
      
      if game.locallyPlayedCard != nil {
         localPlayerDeckTapped()
      }
      if let opponentCard = game.opponentPlayedCard {
         flipOpponentCard(opponentCard)
      }
   }
   
   func updateCounters() {
      DispatchQueue.main.async {
         self.SBopponentCardCounterLabel.text = "\(52 - (self.game.localPlayer.hand?.count ?? 0))"
         self.SBlocalPlayerCardCounterLabel.text = "\(self.game.localPlayer.hand?.count ?? 0)"
      }
   }

   // MARK: UI Animations
   
   func dealCards() {
      func animate(myLocation: CGPoint, theirLocation: CGPoint, toMe: Bool, card: Int) {
         let location = toMe ? myLocation : theirLocation
         let newCard = createCardView(placeholder: SBdealDeckPlaceholder)
         UIView.animate(withDuration: 1, delay: 0, animations: {
            newCard.center = location
            if card > 0 {
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                  animate(myLocation: myLocation, theirLocation: theirLocation, toMe: !toMe, card: card - 1)
               }
            }
         }, completion:{ _ in
            newCard.removeFromSuperview()
            if toMe {
               self.tapHaptic()
               self.SBlocalPlayerDeckPlaceholder.isHidden = false
            } else {
               self.SBopponentDeckPlaceholder.isHidden = false
            }
         })

      }
      
      SBdealDeckPlaceholder.isHidden = false
      view.bringSubviewToFront(SBdealDeckPlaceholder)
      
      let theirLocation = opponentDeckCenter
      let myLocation = localPlayerDeckCenter
      animate(myLocation: myLocation, theirLocation: theirLocation, toMe: false, card: 52)
      
      updateCounters()
      
      SBdealDeckPlaceholder.isHidden = true
   }
   
   func flipOpponentCard(_ card: LGPlayingCard?) {
      guard let card = card else { return }
      opponentPlayedCard = createCardView(LGcard: card, placeholder: SBopponentDeckPlaceholder)
      
      opponentPlayedCard.move(to: opponentPlayedCardCenter, completion: {_ in self.tapHaptic()})
   }
   
   func animateResult() {
      let result = game.retrieveResult()
      var location = CGPoint(x: 0, y: 0)
      switch result {
      case .win:
         location = localPlayerDeckCenter
      case .loss:
         location = opponentDeckCenter
      case .tie:
         break
      default:
         break
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
         if result == .tie {
            self.tiedCards.append(self.opponentPlayedCard)
            self.tiedCards.append(self.localPlayerPlayedCard)
            self.showTie()
            self.SBlocalPlayerDeckPlaceholder.isUserInteractionEnabled = true
         } else {
            self.tiedCards.forEach { cardView in
               self.view.sendSubviewToBack(cardView)
               cardView.move(to: location)
               if cardView.isFaceUp {
                  UIView.transition(with: cardView, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                     cardView.isFaceUp = !cardView.isFaceUp
                  })
               }
            }
            self.tiedCards.removeAll()
            
            self.view.sendSubviewToBack(self.opponentPlayedCard)
            self.opponentPlayedCard.move(to: location)
               
            self.view.sendSubviewToBack(self.localPlayerPlayedCard)
            self.localPlayerPlayedCard.move(to: location, completion: { _ in
               self.updateCounters()
               self.SBlocalPlayerDeckPlaceholder.isUserInteractionEnabled = true
            })
         }
      }
   }
   
   func showTie() {
      func animate(location: CGPoint, dx: CGFloat, dy: CGFloat, card: Int, myDeck: Bool) {
         let newCard = createCardView(placeholder: SBlocalPlayerDeckPlaceholder)
         tiedCards.append(newCard)
         if myDeck {
            newCard.center = SBlocalPlayerDeckPlaceholder.center
         } else {
            newCard.center = SBopponentDeckPlaceholder.center
         }
         UIView.animate(withDuration: 1, delay: 0, animations: {
            newCard.center = location.offsetBy(dx: dx, dy: dy)
            if card > 1 {
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                  animate(location: newCard.center, dx: dx, dy: dy, card: card - 1, myDeck: myDeck)
               }
            }
         }, completion:{ _ in
            self.tapHaptic()
         })
      }
      
      animate(location: localPlayerPlayedCardCenter, dx: 15, dy: 2, card: 3, myDeck: true)
      animate(location: opponentPlayedCardCenter, dx: -15, dy: -2, card: 3, myDeck: false)
   }
   
   // MARK: Notifications
   
   @objc func handleNotifications(_ notification: Notification) {
      typealias type = LGLardGame.NotificationType
      DispatchQueue.main.async{
         switch notification.name {
         case type.refreshedLocation.name:
            self.SBlocalPlayerDeckPlaceholder.refresh(self.game.weather)
            self.SBopponentDeckPlaceholder.refresh(self.game.weather)
         case type.receivedCardPlayed.name:
            self.flipOpponentCard(self.game.opponentPlayedCard)
         case type.dealingHand.name:
            self.dealCards()
         case type.playResultReady.name:
            self.animateResult()
         case type.endedGame.name:
            let alertVC = UIAlertController(title: self.game.gameResultMessage, message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in self.backToMenu()}))
            self.present(alertVC, animated: true, completion: nil)
         case type.playerDisconnected.name:
            if let card = self.opponentPlayedCard {
               card.removeFromSuperview()
            }
            if let card = self.localPlayerPlayedCard {
               card.removeFromSuperview()
            }
            self.backToRejoin()
         default:
            print("Received notification which is unhandled in GameViewController")
         }
      }
   }

}
