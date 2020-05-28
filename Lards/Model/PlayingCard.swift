//
//  PlayingCard.swift
//  Lards
//
//  Created by Shane Lawson on 5/21/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation

enum Rank: Int, Codable, CaseIterable {
   case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
   
   var string: String {
      switch self {
      case .ace:
         return "A"
      case .jack:
         return "J"
      case .queen:
         return "Q"
      case .king:
         return "K"
      default:
         return "\(self.rawValue)"
      }
   }
}

enum Suit: Int, Codable, CaseIterable {
   case spades, hearts, diamonds, clubs
   
   var string: String {
      switch self {
      case .spades:
         return "♠"
      case .hearts:
         return "♥"
      case .diamonds:
         return "♦"
      case .clubs:
         return "♣"
      }
   }
}

struct PlayingCard: Codable, CustomStringConvertible {
   let rank: Rank
   let suit: Suit
   
   init(_ rank: Rank, _ suit: Suit) {
      self.rank = rank
      self.suit = suit
   }
   
   init(from data: Data) {
      do {
         let incomingCard = try JSONDecoder().decode(PlayingCard.self, from: data)
         self.rank = incomingCard.rank
         self.suit = incomingCard.suit
         return
      } catch {
         print("Error decoding as PlayingCard: \(error.localizedDescription)")
      }
      self.rank = Rank(rawValue: 14)!
      self.suit = Suit(rawValue: 5)!
   }
   
   var description: String {
      return rank.string + suit.string
   }
}
