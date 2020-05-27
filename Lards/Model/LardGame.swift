//
//  LardGame.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import CoreLocation
import Foundation
import MultipeerConnectivity
import os

class Player {
   var peerID: MCPeerID
   var displayName: String {
      return peerID.displayName
   }
   
   init(peerID: MCPeerID) {
      self.peerID = peerID
   }
}

class LardGame: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, CLLocationManagerDelegate {
   let serviceType = "lards-newgame"
   enum NotificationType: String {
      case foundHost
      case lostPlayer
      case addedPlayer
      case removedPlayer
      case startingGame
      case receivedRequest
      case refreshedLocation
      
      var name: NSNotification.Name {
         return NSNotification.Name(self.rawValue)
      }
   }
   
   var players: [Player]
   var joinRequests: [MCPeerID: (Bool, MCSession?) -> Void]
   var foundHosts: [MCPeerID]
   var isInSetup: Bool
   var isCreator = false
   var location: CLLocation?
   var isLocationEnabled: Bool {
      CLLocationManager.locationServicesEnabled()
   }
   var weather: WeatherObject?
   
   let peerID: MCPeerID
   let session: MCSession
   let advertiser: MCNearbyServiceAdvertiser
   let browser: MCNearbyServiceBrowser
   let locationManager: CLLocationManager
   
   override init() {
      players = [Player]()
      joinRequests = [MCPeerID: (Bool, MCSession?) -> Void]()
      foundHosts = [MCPeerID]()
      isInSetup = true
      peerID = MCPeerID(displayName: UIDevice.current.name)
//      session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
      session = MCSession(peer: peerID)
      advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
      browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
      locationManager = CLLocationManager()
      
      super.init()
      
      session.delegate = self
      browser.delegate = self
      advertiser.delegate = self
      locationManager.delegate = self
      
   }
   
   deinit {
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
   }
   
   func addPlayer(with peerID: MCPeerID) -> Bool {
      if let invitationHandler = joinRequests[peerID] {
         invitationHandler(true, session)
         joinRequests[peerID] = nil
         return true
      }
      return false
   }
   
   func joinHost(with peerID: MCPeerID) {
      browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
      foundHosts.removeAll { $0 == peerID }
   }
   
   func startGame() {
      if isCreator {
         let packet = LardPacket(.startGame)
         do {
            try broadcast(packet.encoded!)
         } catch {
            print("Error sending to session: \(error.localizedDescription)")
         }
      }
      
      postNotification(of: .startingGame)
      isInSetup = false
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
   }
   
   func startHand() {
      
   }
   
   func didReceive() {
      
   }
   
   func scoreHand() {
      
   }
   
   func startMultipeer(isCreating: Bool) {
      isCreator = isCreating
      if isCreating {
         advertiser.startAdvertisingPeer()
      } else {
         browser.startBrowsingForPeers()
      }
   }
   
   func stopMultipeer() {
      advertiser.stopAdvertisingPeer()
      browser.stopBrowsingForPeers()
   }

   func subscribeToNotifications(of types: [NotificationType], observer: Any, selector: Selector ) {
      types.forEach {
         NotificationCenter.default.addObserver(observer, selector: selector, name: $0.name, object: nil)
      }
   }
   
   func unsubscribeFromNotifications(_ observer: Any) {
      NotificationCenter.default.removeObserver(observer)
   }
   
   func postNotification(of type: NotificationType) {
      NotificationCenter.default.post(name: type.name, object: nil)
      print("sent \(type.rawValue) notification from LardGame")
   }
   
   func broadcast(_ data: Data) throws {
      try session.send(data, toPeers: session.connectedPeers, with: .reliable)
   }
   
   func getLocation() {
      locationManager.requestWhenInUseAuthorization()
      locationManager.requestLocation()
   }
   
   // MARK: - MCSessionDelegate
   
   func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
      do {
         let packet = try JSONDecoder().decode(LardPacket.self, from: data)
         switch packet.type {
         case .startGame:
            self.startGame()
         case .cardPlayed:
            break
         case .reshuffledDeck:
            break
         }
      } catch {
          print("Error decoding LardPacket: \(error.localizedDescription)")
      }
   }
   
   func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
      switch state {
      case .notConnected:
         print("not connected to \(peerID.displayName)")
      case .connecting:
         print("connecting to \(peerID.displayName)")
      case .connected:
         print("connected to \(peerID.displayName)")
         players.append(Player(peerID: peerID))
         postNotification(of: .addedPlayer)
         getLocation()
      @unknown default:
         fatalError("unknown didChange state")
      }
   }
   
   func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
      // stub
   }
   
   func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
      // stub
   }
   
   /* optional delegate method
   func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
      // stub
   }
   */
   
   func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
      // stub
   }
   
   // MARK: - MCNearbyServiceBrowserDelegate
   
   func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
      foundHosts.append(peerID)
      postNotification(of: .foundHost)
   }
   
   func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
      postNotification(of: .lostPlayer)
   }

   func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
      fatalError("failed to start browsing for peers")
   }

   // MARK: - MCNearbyServiceAdvertiserDelegate
   
   func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
      fatalError("failed to start advertising peer")
   }
   
   func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
      postNotification(of: .receivedRequest)
      joinRequests[peerID] = invitationHandler
   }

   // MARK: - CLLocationManagerDelegate
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      location = locations.last
      print("updated location")
      OpenWeatherMapAPI.getCurrentWeather(at: location!.coordinate) { (weather, error) in
         print("weather returned")
         self.weather = weather!
         self.postNotification(of: .refreshedLocation)
      }
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("location error")
      switch (error as! CLError).code {
      case .denied:
         manager.stopUpdatingLocation()
      default:
         break
      }
   }
}
