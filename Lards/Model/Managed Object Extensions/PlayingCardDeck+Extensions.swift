//
//  PlayingCardDeck+Extensions.swift
//  Lards
//
//  Created by Shane Lawson on 5/29/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation

extension PlayingCardDeck {
   // create a deck with cards on creation
   public override func awakeFromInsert() {
      Suit.allCases.forEach { suit in
         Rank.allCases.forEach { rank in
            let newCard = PlayingCard(context: self.managedObjectContext!)
            newCard.rankValue = rank.rawValue
            newCard.suitValue = suit.rawValue
            self.addToCards(newCard)
         }
      }
   }
   
   // create a CoreData deck object from a non-CoreData deck object
   convenience init(from lgPlayingCardDeck: LGPlayingCardDeck) {
      self.init(context: DataController.shared.viewContext)
      self.cards = []
      lgPlayingCardDeck.cards.forEach { card in
         let newCard = PlayingCard(context: self.managedObjectContext!)
         newCard.rankValue = card.rank.rawValue
         newCard.suitValue = card.suit.rawValue
         self.addToCards(newCard)
      }
      try? managedObjectContext?.save()
   }
   
   func shuffle() {
      let mutableDeck = cards?.mutableCopy() as! NSMutableOrderedSet
      var indices = [Int](0..<52)
      indices.shuffle()
      for i in 0..<indices.count {
         mutableDeck.exchangeObject(at: i, withObjectAt: indices[i])
      }
      cards = mutableDeck
   }
}
