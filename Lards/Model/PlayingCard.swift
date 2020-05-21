//
//  PlayingCard.swift
//  Lards
//
//  Created by Shane Lawson on 5/21/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation

enum Rank: Int, Codable {
   case none, ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
   
   var string: String {
      switch self {
      case .none:
         return ""
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

enum Suit: Int, Codable {
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

struct PlayingCard: Codable {
   let rank: Rank
   let suit: Suit
}
