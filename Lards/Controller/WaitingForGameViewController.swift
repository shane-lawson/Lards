//
//  WaitingForGameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/20/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class WaitingForGameViewController: UIViewController, UITableViewDataSource {

   // MARK: Injected Properties

   var game: LGLardGame!
   var host: String?

   // MARK: IBOutlets

   @IBOutlet weak var navBar: UINavigationItem!
   @IBOutlet weak var tableView: UITableView!

   // MARK: Overrides
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.dataSource = self
      tableView.isUserInteractionEnabled = false
      
      let activityIndicator = UIActivityIndicatorView()
      activityIndicator.startAnimating()
      navBar.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
      if let host = host {
         navBar.title = "\(host)'s Game"
      } else {
         navBar.title = "Waiting for players to rejoin"
      }
      
      game.subscribeToNotifications(of: [.addedPlayer, .removedPlayer, .startingGame], observer: self, selector: #selector(handleNotifications(_:)))
   }

   // MARK: Notifications
   
   @objc func handleNotifications(_ notification: Notification) {
      typealias type = LGLardGame.NotificationType
      DispatchQueue.main.async {
         switch notification.name {
         case type.addedPlayer.name:
            self.performSegue(withIdentifier: "startGame", sender: nil)
         case type.removedPlayer.name:
            self.tableView.reloadData()
         case type.startingGame.name:
            self.performSegue(withIdentifier: "startGame", sender: nil)
         default:
            print("Received notification which is unhandled in WaitingForGameTableViewController")
         }
      }
   }
   
   // MARK: - UITableViewDataSource

   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "Players"
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return game.joinedPlayers?.count ?? game.coreDataGame.players?.count ?? 0
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)

      cell.textLabel?.text = game.joinedPlayers?[indexPath.row].displayName ?? (game.coreDataGame.players?.firstObject as! Player).displayName

      return cell
   }

   // MARK: - Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      switch segue.identifier {
      case "startGame":
         let gameVC = segue.destination as! GameViewController
         gameVC.game = game
      default:
         break
      }
   }

   @IBAction func backToRejoin(_ segue: UIStoryboardSegue) {
      // nothing
   }
   
}
