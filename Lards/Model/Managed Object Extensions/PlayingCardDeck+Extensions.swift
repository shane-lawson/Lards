//
//  PlayingCardDeck+Extensions.swift
//  Lards
//
//  Created by Shane Lawson on 5/29/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation

extension PlayingCardDeck {
   public override func awakeFromInsert() {
      Suit.allCases.forEach { suit in
         Rank.allCases.forEach { rank in
            let newCard = PlayingCard(context: self.managedObjectContext!)
            newCard.rank = rank.rawValue
            newCard.suit = suit.rawValue
         }
      }
   }
}
