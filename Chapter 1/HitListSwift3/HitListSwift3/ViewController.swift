//
//  ViewController.swift
//  HitListSwift3
//
//  Created by Christopher Myers on 10/20/16.
//  Copyright © 2016 Dragoman Developers, LLC. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people : [NSManagedObject] = []
    
   // var names : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Updates the title of View Controller (only if in nav bar)
        self.title = "The List"
        
        // sets up the Reuse Identifier normally done in the storyboard
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        fetchData()
        
    }

    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Name", message: "Add a name to your hit list", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    func save(name : String) {
        
        // Step 1: acces the App Delegate file which contains the CD stuff...
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // Step 2: accessing the managed object context from the app delegate's persistent Container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Step 3 : Create a new managed object and insert it into the managed object context---which lives in the persistent container.
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext) // links data model to entity definition
        
        let person = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        // tell the person managed object what attribute to access and set the information typed by the user to appropriate key name
        person.setValue(name, forKey: "name")
        
        // save the managed object to the Core Data store and append the person to the array of managed objects (to load the tableView)
        
        do {
          try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchData() {
        
        // get acces to the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // access context to peristent Container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // create a fetchRequest from the container using KVC
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            self.people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let person = people[indexPath.row]
        
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.people.remove(at: indexPath.row)
            self.tableView.reloadData()
            
            // need to save the state to Core Data ---remove managed object...
        }
    }
    
}

