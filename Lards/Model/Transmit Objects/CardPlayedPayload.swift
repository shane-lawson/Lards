//
//  CardPlayedPayload.swift
//  Lards
//
//  Created by Shane Lawson on 5/21/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct CardPlayedPayload: Codable {
   let archivedPlayer: Data
   let card: LGPlayingCard
   
   init(_ card: LGPlayingCard, player: Player) {
      self.card = card
      self.archivedPlayer = try! NSKeyedArchiver.archivedData(withRootObject: player.peerID, requiringSecureCoding: false)
   }
   
   init(from data: Data) {
      do {
         let incomingObject = try JSONDecoder().decode(CardPlayedPayload.self, from: data)
         self.card = incomingObject.card
         self.archivedPlayer = incomingObject.archivedPlayer
         return
      } catch {
         print("Error decoding as PlayingCardDeck: \(error.localizedDescription)")
      }
      // ideally should reach here, but needed to stop compiler errors
      self.card = LGPlayingCard(Rank(rawValue: 14)!,Suit(rawValue: 5)!)
      self.archivedPlayer = Data()
   }
   
   var player: LGPlayer {
      let peerID = try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: archivedPlayer)!
      return LGPlayer(peerID: peerID)
   }
}
