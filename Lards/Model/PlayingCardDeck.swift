//
//  PlayingCardDeck.swift
//  Lards
//
//  Created by Shane Lawson on 5/27/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
import UIKit

// non-CoreData PlayingCardDeck model object
// used to encode a deck to broadcast to other players (so all players have the same deck) where it's converted into a CoreData PlayingCardDeck on receipt
class LGPlayingCardDeck: Codable, CustomStringConvertible {
   var cards = [LGPlayingCard]()
   
   init() {
      Suit.allCases.forEach { suit in
         Rank.allCases.forEach { rank in
            cards.append(LGPlayingCard(rank, suit))
         }
      }
   }
   
   init(_ deck: PlayingCardDeck) {
      deck.cards!.forEach { card in
         let playingCard = card as! PlayingCard
         let lgPlayingCard = LGPlayingCard(playingCard.rank, playingCard.suit)
         self.cards.append(lgPlayingCard)
      }
   }
   
   init(from data: Data) {
      do {
         let incomingDeck = try JSONDecoder().decode(LGPlayingCardDeck.self, from: data)
         self.cards = incomingDeck.cards
      } catch {
         print("Error decoding as PlayingCardDeck: \(error.localizedDescription)")
      }
   }
   
   func shuffle() {
      cards.shuffle()
   }
   
   var description: String {
      let newLine = "\n"
      let line = "-------------"
      var string = String()
      string.append(newLine)
      string.append(line)
      string.append(newLine)
      string.append("Name: \(UIDevice.current.name)")
      string.append(newLine)
      string.append(line)
      string.append(newLine)
      cards.forEach { string.append("\($0) "); string.append(newLine) }
      return string
   }
}
