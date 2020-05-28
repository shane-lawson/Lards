//
//  PlayingCardDeck.swift
//  Lards
//
//  Created by Shane Lawson on 5/27/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
import UIKit

class PlayingCardDeck: Codable, CustomStringConvertible {
   var cards = [PlayingCard]()
   
   init() {
      Suit.allCases.forEach { suit in
         Rank.allCases.forEach { rank in
            cards.append(PlayingCard(rank, suit))
         }
      }
   }
   
   init(from data: Data) {
      do {
         let incomingDeck = try JSONDecoder().decode(PlayingCardDeck.self, from: data)
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
