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

// packet to encode a data payload to send specific messages amongst clients
struct LardPacket: Codable {
   let type: PacketType
   private(set) var payload: Data?
   
   // init packet with no payload
   init(_ type: PacketType) {
      self.type = type
   }
   
   // init packet with encodable payload
   init<T: Encodable>(_ type: PacketType, payload: T) {
      self.type = type
      self.payload = encode(payload)
   }
   
//   // init packet with archivable payload
//   init<T: NSCoding>(_ type: PacketType, payload: T) {
//      self.type = type
//      self.payload = archive(payload)
//   }
   
   // encode payload to data for packet
   func encode<T: Encodable>(_ value: T) -> Data? {
      do {
         return try JSONEncoder().encode(value)
      } catch {
         print("Error encoding payload of LardPacket: \(error.localizedDescription)")
      }
      return nil
   }
   
//   // archive payload to data for packet
//   func archive<T: NSCoding>(_ value: T) -> Data? {
//      do {
//         return try NSKeyedArchiver.archivedData(withRootObject: value.self, requiringSecureCoding: true)
//      } catch {
//         print("Error archiving payload of LardPacket: \(error.localizedDescription)")
//      }
//      return nil
//   }
//
   
   // return encoded packet for broadcasting
   var encoded: Data? {
      do {
         return try JSONEncoder().encode(self)
      } catch {
         print("Error encoding LardPacket: \(error.localizedDescription)")
      }
      return nil
   }

}
