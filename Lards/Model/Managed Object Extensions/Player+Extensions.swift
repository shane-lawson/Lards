//
//  Player+Extensions.swift
//  Lards
//
//  Created by Shane Lawson on 5/30/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension Player {
   var displayName: String {
      return peerID.displayName
   }
   
   // return unarchived PeerID object from binary data in CoreData model and archive PeerID object to binary data for storage
   var peerID: MCPeerID {
      get {
         return try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: self.peerIDData!)!
      }
      set (newPeerID) {
         self.peerIDData = try! NSKeyedArchiver.archivedData(withRootObject: newPeerID, requiringSecureCoding: true)
      }
   }
}
