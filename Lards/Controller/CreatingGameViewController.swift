//
//  CreatingGameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class CreatingGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   // MARK: Injected Properties
   
   var game: LGLardGame!
   
   //MARK: IBOutlets
   
   @IBOutlet weak var navBar: UINavigationItem!
   @IBOutlet weak var loadingLabel: UILabel!
   @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   @IBOutlet weak var playerTableView: UITableView!
   
   // MARK: Properties
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      playerTableView.dataSource = self
      playerTableView.delegate = self

      setupUI()
      setLoading(true)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      game.subscribeToNotifications(of: [.receivedRequest, .addedPlayer], observer: self, selector: #selector(processNotifications(_:)))
      game.startMultipeer(isCreating: true)
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      game.unsubscribeFromNotifications(self)
      game.stopMultipeer()
   }

   @objc func cancel() {
      dismiss(animated: true, completion: nil)
   }
   
   func setupUI() {
      navBar.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.done))
      navBar.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
      
   }

   func setLoading(_ isLoading: Bool) {
      activityIndicator.isHidden = !isLoading
      loadingLabel.isHidden = !isLoading
      playerTableView.isHidden = isLoading
   }

   @objc func processNotifications(_ notification: Notification) {
      typealias type = LGLardGame.NotificationType
      DispatchQueue.main.async { [unowned self] in
         switch notification.name {
         case type.addedPlayer.name:
            self.playerTableView.reloadData()
         case type.receivedRequest.name:
            self.setLoading(false)
            self.playerTableView.reloadData()
         default:
            print("Received notification of unknown type.")
         }
         print("received \(notification.name.rawValue) notification in CreatingGameViewController")
      }
   }
   
   @objc func done() {
      game.startGame()
      performSegue(withIdentifier: "startGame", sender: nil)
   }
   
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      game.unsubscribeFromNotifications(self)
      switch segue.identifier {
      case "startGame":
         let gameVC = segue.destination as! GameViewController
         gameVC.game = game
      default:
         break
      }
   }

   // MARK: - UITableViewDataSource
   
   func numberOfSections(in tableView: UITableView) -> Int {
//      var sections = 0
//      if !game.players.isEmpty { sections += 1 }
//      if !game.joinRequests.isEmpty { sections += 1 }
      return 2
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0:
         return game.joinRequests.count
      case 1:
         return game.joinedPlayers.count
      default:
         return 0
      }
   }
   
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      switch section {
      case 0:
         return "Requesting to Join"
      case 1:
         return "Added to Game"
      default:
         return nil
      }
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
      cell.textLabel?.text = displayName(at: indexPath)
      return cell
   }
   
   func displayName(at indexPath: IndexPath) -> String {
      switch indexPath.section {
      case 0:
         let keys = game.joinRequests.keys.map { $0 }
         return keys[indexPath.row].displayName
      case 1:
         return game.joinedPlayers[indexPath.row].displayName
      default:
         fatalError("section does not exist")
      }
   }
   
   // MARK: - UITableViewDelegate
   
   func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      switch indexPath.section {
      case 0:
         return indexPath
      case 1:
         return nil
      default:
         fatalError("section does not exist")
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      switch indexPath.section {
      case 0:
         let keys = game.joinRequests.keys.map { $0 }
         if game.addPlayer(with: keys[indexPath.row]) {
            tableView.reloadData()
         }
      case 1:
         break
      default:
         fatalError("section does not exist")
      }
   }
   
}
