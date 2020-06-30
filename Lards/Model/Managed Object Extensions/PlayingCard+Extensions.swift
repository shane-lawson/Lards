//
//  PlayingCard+Extensions.swift
//  Lards
//
//  Created by Shane Lawson on 5/29/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import CoreData
import Foundation

extension PlayingCard {
   // copy constructor
   convenience init(context: NSManagedObjectContext, card copy: PlayingCard) {
      self.init(context: context)
      self.rankValue = copy.rankValue
      self.suitValue = copy.suitValue
   }
   
   // return rank and suit object which are encoded as integers in CoreData object
   var rank: Rank {
      return Rank(rawValue: self.rankValue)!
   }
   
   var suit: Suit {
      return Suit(rawValue: self.suitValue)!
   }
}
