//
//  LardGame.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation
import MultipeerConnectivity
import os

class LGPlayer: NSObject {
   var peerID: MCPeerID
   var displayName: String
   var session: MCSession?
   
   init(peerID: MCPeerID) {
      self.peerID = peerID
      self.displayName = peerID.displayName
      super.init()
   }
}

class LGLardGame: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, CLLocationManagerDelegate {
   let newGameServiceType = "lards-newgame"
   let resumeGameServiceType = "lards-rgame"
   enum NotificationType: String {
      case foundHost
      case lostPlayer
      case addedPlayer
      case removedPlayer
      case startingGame
      case receivedRequest
      case refreshedLocation
      case receivedCardPlayed
      case dealingHand
      case playResultReady
      case endedGame
      case playerDisconnected
      
      var name: NSNotification.Name {
         return NSNotification.Name(self.rawValue)
      }
   }
   
   enum PlayResult {
      case win, loss, tie, none
   }
   
   var coreDataGame: LardGame!
   
   var joinedPlayers: [LGPlayer]?
   var joinRequests: [MCPeerID: (Bool, MCSession?) -> Void]?
   var foundHosts: [MCPeerID]?
   var isInSetup: Bool?
   var isCreator = false
   var isResumingGame = false
   var location: CLLocation?
   var isLocationEnabled: Bool {
      CLLocationManager.locationServicesEnabled()
   }
   var weather: WeatherObject?
   var deck: LGPlayingCardDeck?
   var localPlayer: Player!
   
   var locallyPlayedCard: LGPlayingCard? = nil
   var opponentPlayedCard: LGPlayingCard? = nil
   private var playResult: PlayResult? = nil
   var tiebreakerCards: [PlayingCard]? = nil
   var gameResultMessage: String? = nil
   
   let peerID: MCPeerID
   let session: MCSession
   let advertiser: MCNearbyServiceAdvertiser
   let browser: MCNearbyServiceBrowser
   let locationManager: CLLocationManager
   
   override init() {
      joinedPlayers = [LGPlayer]()
      joinRequests = [MCPeerID: (Bool, MCSession?) -> Void]()
      foundHosts = [MCPeerID]()
      isInSetup = true
      peerID = LardsUserDefaults.peerID
      session = MCSession(peer: peerID)
      advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: newGameServiceType)
      browser = MCNearbyServiceBrowser(peer: peerID, serviceType: newGameServiceType)
      locationManager = CLLocationManager()
      
      super.init()
      
      session.delegate = self
      browser.delegate = self
      advertiser.delegate = self
      locationManager.delegate = self
   }
   
   init(coreDataGame game: LardGame) {
      self.coreDataGame = game
      self.localPlayer = coreDataGame.localPlayer
      self.peerID = localPlayer.peerID
      self.session = MCSession(peer: peerID)
      self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: resumeGameServiceType)
      self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: resumeGameServiceType)
      self.locationManager = CLLocationManager()
      self.isResumingGame = true
      self.isCreator = game.isCreator
      
      super.init()
      
      session.delegate = self
      browser.delegate = self
      advertiser.delegate = self
      locationManager.delegate = self
      
      resumeGame()
   }
   
   deinit {
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
   }
   
   @objc func didEnterBackground() {
      session.disconnect()
      print("disconnected session.")
   }
   
   func addPlayer(with peerID: MCPeerID) -> Bool {
      if let invitationHandler = joinRequests?[peerID] {
         invitationHandler(true, session)
         joinRequests?[peerID] = nil
         return true
      }
      return false
   }
   
   func joinHost(with peerID: MCPeerID) {
      browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
      print("initially invited \(peerID.displayName) to session:")
      print(peerID)
      foundHosts?.removeAll { $0 == peerID }
   }
   
   func createCoreDataGame() {
      coreDataGame = LardGame(context: DataController.shared.viewContext)
      localPlayer = Player(context: DataController.shared.viewContext)
      localPlayer.peerID = peerID
      coreDataGame.localPlayer = localPlayer
      joinedPlayers!.forEach {
         let player = Player(context: DataController.shared.viewContext)
         player.peerID = $0.peerID

         coreDataGame.addToPlayers(player)
      }
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .medium
      dateFormatter.timeStyle = .short
      coreDataGame.displayName = "\(dateFormatter.string(from: Date()))"
      coreDataGame.isCreator = isCreator
      
      DataController.shared.saveContext()
   }
   
   func saveDeck() {
      coreDataGame.deck = PlayingCardDeck(context: DataController.shared.viewContext)
      coreDataGame.deck?.shuffle()
      DataController.shared.saveContext()
   }
   
   func startGame() {
      createCoreDataGame()
      if isCreator {
         let packet = LardPacket(.startGame)
         do {
            try broadcast(packet.encoded!)
         } catch {
            print("Error sending startGame packet to session: \(error.localizedDescription)")
         }
         
         saveDeck()
         
         // can't seem to archive PlayingCardDeck for some reason, so I'll convert to an LGPLayingCardDeck to transfer, then recreate it on the receiving side
//         let data = try! NSKeyedArchiver.archivedData(withRootObject: coreDataGame.deck.self!, requiringSecureCoding: false)
         let lgDeck = LGPlayingCardDeck(coreDataGame.deck!)
         let deckPacket = LardPacket(.reshuffledDeck, payload: lgDeck)
         do {
            try broadcast(deckPacket.encoded!)
         } catch {
            print("Error sending reshuffledDeck packet to session: \(error.localizedDescription)")
         }
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.startHand()
         }
      }
      
      postNotification(of: .startingGame)
      isInSetup = false
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
      
   }
   
   func resumeGame() {
      startMultipeer(isCreating: isCreator)
      
      if !isCreator {
         let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
         let predicate = NSPredicate(format: "game == %@", coreDataGame)
         fetchRequest.predicate = predicate
         if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
            result.forEach {
               self.browser.invitePeer($0.peerID, to: self.session, withContext: nil, timeout: 0)
               print("reinvited \($0.displayName) to game")
            }
         }
      }
   }
   
   func startHand() {
      func deal() {
         var playersInGame = coreDataGame.players!.map{$0 as! Player}
         if isCreator {
            playersInGame.insert(localPlayer, at: 0)
         } else {
            playersInGame.append(localPlayer)
         }
         let numOfPlayers = playersInGame.count
         for i in 0..<52 {
            let card = coreDataGame.deck!.cards![i] as! PlayingCard
            playersInGame[i%numOfPlayers].addToHand(card)
         }
         DataController.shared.saveContext()
      }
      
      deal()
      
      postNotification(of: .dealingHand)
   }
   
   func play() {
      do {
         let playingCard = localPlayer.hand?.firstObject as! PlayingCard
         locallyPlayedCard = LGPlayingCard(from: playingCard)
         let cardPlayedPayload = CardPlayedPayload(locallyPlayedCard!, player: localPlayer!)
         let packet = LardPacket(.cardPlayed, payload: cardPlayedPayload)
         try broadcast(packet.encoded!)
      } catch {
         print("Error sending cardPlayed packet to session: \(error.localizedDescription)")
      }
      evaluateMatchResult()
   }
   
   func evaluateMatchResult() {
      guard
         let locallyPlayedCard = locallyPlayedCard,
         let opponentPlayedCard = opponentPlayedCard
      else {
         return
      }
      
      let localCardFromHand = PlayingCard(context: DataController.shared.viewContext, card: localPlayer.hand?.firstObject as! PlayingCard)
      let opponent = coreDataGame.players?.firstObject as! Player
      let opponentCardFromHand = PlayingCard(context: DataController.shared.viewContext, card: opponent.hand?.firstObject as! PlayingCard)
   
      DataController.shared.viewContext.delete(localPlayer.hand?.firstObject as! PlayingCard)
      DataController.shared.viewContext.delete(opponent.hand?.firstObject  as! PlayingCard)
      DataController.shared.saveContext()
      
      if locallyPlayedCard.rank.rawValue > opponentPlayedCard.rank.rawValue {
         playResult = .win
         localPlayer.addToHand(localCardFromHand)
         localPlayer.addToHand(opponentCardFromHand)
         
         if let tiebreakerCards = tiebreakerCards {
            tiebreakerCards.forEach { card in
               localPlayer.addToHand(card)
            }
         }
         tiebreakerCards = nil
      } else if opponentPlayedCard.rank.rawValue > locallyPlayedCard.rank.rawValue {
         playResult = .loss
         opponent.addToHand(localCardFromHand)
         opponent.addToHand(opponentCardFromHand)
         
         
         if let tiebreakerCards = tiebreakerCards {
            tiebreakerCards.forEach { card in
               opponent.addToHand(card)
            }
         }
         tiebreakerCards = nil
      } else {
         playResult = .tie
         
         if tiebreakerCards == nil {
            tiebreakerCards = [PlayingCard]()
         }
         
         tiebreakerCards?.append(localCardFromHand)
         tiebreakerCards?.append(opponentCardFromHand)
         for _ in 1...3 {
            let localCard = PlayingCard(context: DataController.shared.viewContext, card: localPlayer.hand?.firstObject as! PlayingCard)
            let opponentCard = PlayingCard(context: DataController.shared.viewContext, card: opponent.hand?.firstObject as! PlayingCard)
            DataController.shared.viewContext.delete(localPlayer.hand?.firstObject as! PlayingCard)
            DataController.shared.viewContext.delete(opponent.hand?.firstObject  as! PlayingCard)
            DataController.shared.saveContext()
            tiebreakerCards?.append(localCard)
            tiebreakerCards?.append(opponentCard)
         }
      }
      
      self.locallyPlayedCard = nil
      self.opponentPlayedCard = nil

      
      postNotification(of: .playResultReady)
      
      if localPlayer.hand!.count == 0 {
         gameResultMessage = "You Lost!"
         coreDataGame.isComplete = true
         postNotification(of: .endedGame)
      } else if (coreDataGame.players?.firstObject as! Player).hand!.count == 0 {
         gameResultMessage = "You Won!"
         coreDataGame.isComplete = true
         postNotification(of: .endedGame)
      }
      
      DataController.shared.saveContext()
   }
   
   func retrieveResult() -> PlayResult {
      if let result = playResult {
         playResult = nil
         locallyPlayedCard = nil
         opponentPlayedCard = nil
         return result
      }
      return .none
   }
   
   func startMultipeer(isCreating: Bool) {
      isCreator = isCreating
      if isCreating {
         advertiser.startAdvertisingPeer()
      } else {
         browser.startBrowsingForPeers()
      }
      
      NotificationCenter.default.addObserver(self, selector: #selector(disconnect), name: UIApplication.didEnterBackgroundNotification, object: nil)
   }
   
   @objc func disconnect() {
      session.disconnect()
      DataController.shared.saveContext()
   }
   
   func stopMultipeer() {
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
   }

   func subscribeToNotifications(of types: [NotificationType], observer: Any, selector: Selector ) {
      types.forEach {
         NotificationCenter.default.addObserver(observer, selector: selector, name: $0.name, object: nil)
      }
   }
   
   func unsubscribeFromNotifications(_ observer: Any) {
      NotificationCenter.default.removeObserver(observer)
   }
   
   func postNotification(of type: NotificationType, info: [AnyHashable : Any]? = nil) {
      NotificationCenter.default.post(name: type.name, object: nil, userInfo: info)
      print("sent \(type.rawValue) notification from LardGame")
   }
   
   func broadcast(_ data: Data) throws {
      try session.send(data, toPeers: session.connectedPeers, with: .reliable)
   }
   
   func getLocation() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.requestLocation()
   }
   
   // MARK: - MCSessionDelegate
   
   func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
      do {
         let packet = try JSONDecoder().decode(LardPacket.self, from: data)
         print("received \(packet.type) packet from \(peerID.displayName)")
         switch packet.type {
         case .startGame:
            self.startGame()
         case .cardPlayed:
            let cardPlayedPayload = CardPlayedPayload(from: packet.payload!)
            print("received [\(cardPlayedPayload.card)] from \(cardPlayedPayload.player.displayName)")
            opponentPlayedCard = cardPlayedPayload.card
            postNotification(of: .receivedCardPlayed)
            evaluateMatchResult()
         case .reshuffledDeck:
            coreDataGame.deck = PlayingCardDeck(from: LGPlayingCardDeck(from: packet.payload!))
            startHand()
         }
      } catch {
          print("Error decoding LardPacket: \(error.localizedDescription)")
      }
   }
   
   func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
      switch state {
      case .notConnected:
         print("not connected to \(peerID.displayName)")
         postNotification(of: .playerDisconnected)
      case .connecting:
         print("connecting to \(peerID.displayName)")
      case .connected:
         print("connected to \(peerID.displayName)")
         joinedPlayers?.append(LGPlayer(peerID: peerID))
         postNotification(of: .addedPlayer)
         getLocation()
      @unknown default:
         fatalError("unknown didChange state")
      }
   }
   
   func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
      // stub
   }
   
   func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
      // stub
   }
   
   /* optional delegate method
   func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
      // stub
   }
   */
   
   func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
      // stub
   }
   
   // MARK: - MCNearbyServiceBrowserDelegate
   
   func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
      postNotification(of: .foundHost)
      if isResumingGame {
         coreDataGame.players?.forEach { playerElement in
            let player = playerElement as! Player
            if peerID == player.peerID {
               self.browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 0)
            }
         }
      } else {
         foundHosts?.append(peerID)
      }
   }
   
   func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
      postNotification(of: .lostPlayer)
   }

   func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
      fatalError("failed to start browsing for peers")
   }

   // MARK: - MCNearbyServiceAdvertiserDelegate
   
   func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
      fatalError("failed to start advertising peer")
   }
   
   func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
      postNotification(of: .receivedRequest)
      if isResumingGame {
//         if coreDataGame.players!.contains(where: { (playerElement) -> Bool in
//            let player = playerElement as! Player
//            return player.peerID == peerID
//         }) {
            invitationHandler(true, session)
//         }
      } else {
         joinRequests?[peerID] = invitationHandler
      }
   }

   // MARK: - CLLocationManagerDelegate
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      location = locations.last
      OpenWeatherMapAPI.getCurrentWeather(at: location!.coordinate) { (weather, error) in
         self.weather = weather!
         self.postNotification(of: .refreshedLocation)
      }
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      switch (error as! CLError).code {
      case .denied:
         manager.stopUpdatingLocation()
      default:
         break
      }
   }
}
