//
//  LardsUserDefaults.swift
//  Lards
//
//  Created by Shane Lawson on 5/27/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class LardsUserDefaults {
   
   // enum so that mistyped string keys aren't an issue
   enum Keys: String {
      case peerID, displayName, haptics, gestures, color, hasLaunchedBefore
   }
  
   // check for first launch (for use in AppDelegate) and initialise default values
   class func checkIfFirstLaunch() {
      if UserDefaults.standard.bool(forKey: Keys.hasLaunchedBefore.rawValue) {
      } else {
         UserDefaults.standard.set(true, forKey: Keys.hasLaunchedBefore.rawValue)
         archiveAndSet(peerID: MCPeerID(displayName: UIDevice.current.name))
         UserDefaults.standard.set(UIDevice.current.name, forKey: Keys.displayName.rawValue)
         UserDefaults.standard.set(true, forKey: Keys.haptics.rawValue)
         UserDefaults.standard.set(true, forKey: Keys.gestures.rawValue)
         archiveAndSet(color: UIColor.systemGreen)
         UserDefaults.standard.synchronize()
      }
   }
   
   fileprivate class func archiveAndSet(peerID: MCPeerID) {
      let data = try! NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: false)
      UserDefaults.standard.set(data, forKey: Keys.peerID.rawValue)
   }
   
   fileprivate class func archiveAndSet(color: UIColor) {
      let data = try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
      UserDefaults.standard.set(data, forKey: Keys.color.rawValue)
   }
   
   static var peerID: MCPeerID {
      get {
         let data = UserDefaults.standard.data(forKey: Keys.peerID.rawValue)!
         return try! NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data)!
      }
   }
   
   static var accentColor: UIColor {
      get {
         let data = UserDefaults.standard.data(forKey: Keys.color.rawValue)!
         return try! NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)!
      }
      set(newColor) {
         archiveAndSet(color: newColor)
      }
   }
      
   static var displayName: String {
      get {
         return UserDefaults.standard.string(forKey: Keys.displayName.rawValue)!
      }
      set(newDisplayName) {
         UserDefaults.standard.set(newDisplayName, forKey: Keys.displayName.rawValue)
         archiveAndSet(peerID: MCPeerID(displayName: newDisplayName))
      }
   }
   
   static var gestures: Bool {
      get {
         return UserDefaults.standard.bool(forKey: Keys.gestures.rawValue)
      }
      set(newValue) {
         UserDefaults.standard.set(newValue, forKey: Keys.gestures.rawValue)
      }
   }
   
   static var haptics: Bool {
      get {
         return UserDefaults.standard.bool(forKey: Keys.gestures.rawValue)
      }
      set(newValue) {
         UserDefaults.standard.set(newValue, forKey: Keys.gestures.rawValue)
      }
   }

}
