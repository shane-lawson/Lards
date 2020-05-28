//
//  DataController.swift
//  Lards
//
//  Created by Shane Lawson on 5/27/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import CoreData
import Foundation

class DataController {
   static let shared = DataController(modelName: "Lards")
   
   let persistentContainer: NSPersistentContainer
   
   var viewContext: NSManagedObjectContext {
      return persistentContainer.viewContext
   }
   
   init(modelName: String) {
      persistentContainer = NSPersistentContainer(name: modelName)
   }
   
   func load(completion: (() -> Void)? = nil) {
      persistentContainer.loadPersistentStores { (storeDescription, error) in
         guard error == nil else { fatalError(error!.localizedDescription) }
         completion?()
      }
   }
}
