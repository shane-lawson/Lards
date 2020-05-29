//
//  LoadGameViewController.swift
//  Lards
//
//  Created by Shane Lawson on 5/13/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import CoreData
import UIKit

class LoadGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   @IBOutlet weak var tableView: UITableView!
   
   var games: [[LardGame]]?
   var sectionTitles = [String]()
   
   var selectedGame: LardGame?
   
   override func viewDidLoad() {
      super.viewDidLoad()

      tableView.dataSource = self
      tableView.delegate = self
      
      performFetch()
   }

   func performFetch() {
      let fetchRequest: NSFetchRequest<LardGame> = LardGame.fetchRequest()
      if let result = try? DataController.shared.viewContext.fetch(fetchRequest) {
         let incomplete = result.filter{!$0.isComplete}.map{$0}
         let complete = result.filter{$0.isComplete}.map{$0}
         if !incomplete.isEmpty || !complete.isEmpty {
            games = [[LardGame]]()
            games!.append(incomplete)
            games!.append(complete)
            if !incomplete.isEmpty {
               sectionTitles.append("Games in Progress")
            } else {
               sectionTitles.append("")
            }
            if !complete.isEmpty {
               sectionTitles.append("Completed Games")
            } else {
               sectionTitles.append("")
            }
         }
      }
   }

   // MARK: Navigation

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      switch segue.identifier {
      case "resumeGame":
         let gameVC = segue.destination as! GameViewController
         // TODO: use core data model objects
//         gameVC.game = selectedGame
      default:
         break
      }
   }

   // MARK: - UITableViewDataSource
   
   func numberOfSections(in tableView: UITableView) -> Int {
      return games?.count ?? 1
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return games?[section].count ?? 0
   }
   
   func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      guard !sectionTitles.isEmpty else { return "No games" }
      return sectionTitles[section]
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "gameCell", for: indexPath)
      cell.textLabel?.text = game(at: indexPath).displayName
      return cell
   }
   
   // MARK: - UITableViewDelegate
   
   func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      if indexPath.section == 0 {
         return indexPath
      } else {
         return nil
      }
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      selectedGame = game(at: indexPath)
      performSegue(withIdentifier: "resumeGame", sender: self)
   }
   
   fileprivate func game(at indexPath: IndexPath) -> LardGame {
      return (games?[indexPath.section][indexPath.row])!
   }
   
}
