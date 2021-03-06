//
//  CreatingGameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class CreatingGameViewController: UIViewController, UITableViewDataSource {

   // MARK: Injected Properties
   
   var game: LardGame!
   var isCreating: Bool!
   
   //MARK: IBOutlets
   
   @IBOutlet weak var navBar: UINavigationItem!
   @IBOutlet weak var loadingLabel: UILabel!
   @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   @IBOutlet weak var playerTableView: UITableView!
   
   // MARK: Properties
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      playerTableView.dataSource = self
//      playerTableView.delegate = self

      setLoading(true)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      game.subscribeToNotifications(of: [.foundPlayer, .addedPlayer, .startingGame], observer: self, selector: #selector(processNotifications(_:)))
      game.startMultipeer(isCreating: isCreating)
      setupUI()
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
      navBar.title = isCreating ? "Creating Game" : "Joining Game"
      navBar.rightBarButtonItem = isCreating ? UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.done)) : nil
      navBar.leftBarButtonItem = isCreating ? UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel)) : nil
      loadingLabel.text = isCreating ? "Waiting for players to join" : "Joining game"
   }

   func setLoading(_ isLoading: Bool) {
      activityIndicator.isHidden = !isLoading
      loadingLabel.isHidden = !isLoading
      playerTableView.isHidden = isLoading
   }

   @objc func processNotifications(_ notification: Notification) {
      typealias type = LardGame.NotificationType
      DispatchQueue.main.async { [unowned self] in
         switch notification.name {
         case type.addedPlayer.name:
            self.setLoading(false)
            self.playerTableView.reloadData()
         case type.foundPlayer.name:
            print("received foundPlayer notification")
         case type.lostPlayer.name:
            print("received lostPlayer notification")
         case type.removedPlayer.name:
            print("received removedPlayer notification")
         case type.startingGame.name:
            print("received startingGame notification")
         default:
            print("Received notification of unknown type.")
         }
      }
   }
   
   @objc func done() {
      print("done tapped")
   }
   
   /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // Get the new view controller using segue.destination.
      // Pass the selected object to the new view controller.
   }
   */

   // MARK: - UITableViewDataSource
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return game.players.count
   }
   
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "Players"
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
      cell.textLabel?.text = player(at: indexPath).displayName
      return cell
   }
   
   func player(at indexPath: IndexPath) -> Player {
      return game.players[indexPath.row]
   }
   
   // MARK: - UITableViewDelegate
   
   
   
}
