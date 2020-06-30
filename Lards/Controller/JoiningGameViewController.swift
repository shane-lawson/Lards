//
//  JoiningGameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class JoiningGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   // MARK: Injected Properties
   
   var game: LGLardGame!
   
   //MARK: IBOutlets
   
   @IBOutlet weak var navBar: UINavigationItem!
   @IBOutlet weak var loadingLabel: UILabel!
   @IBOutlet weak var titleBarActivityIndicator: UIActivityIndicatorView!
   @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   @IBOutlet weak var playerTableView: UITableView!
   
   // MARK: Properties
   
   var selectedHost: String?
   
   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      playerTableView.dataSource = self
      playerTableView.delegate = self
      
      setLoading(true)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      game.subscribeToNotifications(of: [.foundHost, .addedPlayer], observer: self, selector: #selector(handleNotifications(_:)))
      game.startMultipeer(isCreating: false)
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      game.unsubscribeFromNotifications(self)
      game.stopMultipeer()
   }
   
   // MARK: UI Updates

   func setLoading(_ isLoading: Bool) {
      if isLoading {
         activityIndicator.startAnimating()
      } else {
         activityIndicator.stopAnimating()
         titleBarActivityIndicator.startAnimating()
      }
      loadingLabel.isHidden = !isLoading
      playerTableView.isHidden = isLoading
   }
   
   // MARK: Notifications
   
   @objc func handleNotifications(_ notification: Notification) {
      typealias type = LGLardGame.NotificationType
      DispatchQueue.main.async { [unowned self] in
         switch notification.name {
         case type.foundHost.name:
            self.setLoading(false)
            self.playerTableView.reloadData()
         case type.addedPlayer.name:
            self.performSegue(withIdentifier: "moveToWaiting", sender: nil)
         case type.startingGame.name:
            self.performSegue(withIdentifier: "startGame", sender: nil)
         default:
            print("Received notification which is unhandled in JoiningGameViewController")
         }
      }
   }

   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      game.unsubscribeFromNotifications(self)
      switch segue.identifier {
      case "moveToWaiting":
         let waitingVC = segue.destination as! WaitingForGameViewController
         waitingVC.game = game
         waitingVC.host = selectedHost
      case "startGame":
         let gameVC = segue.destination as! GameViewController
         gameVC.game = game
      default:
         break
      }
   }

   // MARK: - UITableViewDataSource
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return game.foundHosts!.count
   }
   
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "Hosts"
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
      cell.textLabel?.text = game.foundHosts![indexPath.row].displayName
      cell.detailTextLabel?.textColor = .systemGray2
      return cell
   }

   // MARK: - UITableViewDelegate
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if selectedHost == nil {
         let peerID = game.foundHosts![indexPath.row]
         game.joinHost(with: peerID)
         titleBarActivityIndicator.stopAnimating()
         tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Request Sent"
         selectedHost = peerID.displayName
      }
      tableView.deselectRow(at: indexPath, animated: true)
   }
   
}
