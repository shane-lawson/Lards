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
   var payload: Data?
   
   init(_ type: PacketType, payload: Any? = nil) {
      self.type = type
      if let payload = payload {
         switch type {
         case .startGame:
            self.payload = encode(payload as! StartGamePayload)
         case .cardPlayed:
            self.payload = encode(payload as! CardPlayedPayload)
         case .reshuffledDeck:
            self.payload = encode(payload as! ReshuffledDeckPayload)
//         @unknown default:
//            fatalError("PacketType encoding not implemented in LardPacket")
         }
      } else {
         self.payload = nil
      }
   }
   
   func encode<T>(_ value: T) -> Data? where T: Encodable {
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
