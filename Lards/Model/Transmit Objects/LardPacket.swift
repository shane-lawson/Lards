//
//  LardPacket.swift
//  Lards
//
//  Created by Shane Lawson on 5/21/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation

enum PacketType: Int, Codable {
   case startGame
   case cardPlayed
   case reshuffledDeck
}

struct LardPacket: Codable {
   let type: PacketType
   private(set) var payload: Data?
   
   init(_ type: PacketType) {
      self.type = type
   }
   
   init<T: Encodable>(_ type: PacketType, payload: T) {
      self.type = type
      self.payload = encode(payload)
   }
   
   func encode<T: Encodable>(_ value: T) -> Data? {
      do {
         return try JSONEncoder().encode(value)
      } catch {
         print("Error encoding payload of LardPacket: \(error.localizedDescription)")
      }
      return nil
   }
   
   var encoded: Data? {
      do {
         return try JSONEncoder().encode(self)
      } catch {
         print("Error encoding LardPacket: \(error.localizedDescription)")
      }
      return nil
   }

}
