//
//  ViewController.swift
//  CoreData-Swift
//
//  Created by narendra.vadde on 30/01/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var items:[Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchPeople()
    }
    
    func relationShipDemo() {
        
        if let context = self.context {
            let family = Family(context: context)
            family.name = "Vaddera"
            
            let person = Person(context: context)
            person.name = "Sreenivas"
            //person.family = family
            
            family.addToPeople(person)
        }
        
        do {
            try context?.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchPeople() {
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
//            let pred = NSPredicate(format: "name CONTAINS %@", "gopal")
//            request.predicate = pred
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.items = try context?.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "ADD PERSON", message: "Enter the person name", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "ADD", style: .default) { (action) in
            let nameTextField = alert.textFields?[0]
            
            if let context = self.context {
                let newPerson = Person(context: context)
                newPerson.name = nameTextField?.text
                newPerson.age = 20
                newPerson.gender = "male"
            }
            
            do {
                try self.context?.save()
            } catch {
                print(error.localizedDescription)
            }
            
            self.fetchPeople()
            
        }
        alert.addAction(submitButton)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath)
        let person = items?[indexPath.row]
        cell.textLabel?.text = person?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = self.items?[indexPath.row]
        
        let alert = UIAlertController(title: "EDIT PERSON", message: "Do the corrections in the person", preferredStyle: .alert)
        alert.addTextField()
        
        let nameTextField = alert.textFields?[0]
        nameTextField?.text = person?.name
        
        let saveButton = UIAlertAction(title: "SAVE", style: .default) { (action) in
            let nameTextField = alert.textFields?[0]
            person?.name = nameTextField?.text
            
            do {
                try self.context?.save()
            } catch {
                print(error.localizedDescription)
            }
            
            self.fetchPeople()
        }
        
        alert.addAction(saveButton)
        
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            let personToRemove = self.items?[indexPath.row]
            
            if let selectedPerson = personToRemove {
                self.context?.delete(selectedPerson)
            }
            
            do {
                try self.context?.save()
            } catch {
                print(error.localizedDescription)
            }
            
            self.fetchPeople()
            
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
