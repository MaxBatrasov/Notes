//
//  ViewController.swift
//  Notes
//
//  Created by Максим Батрасов on 27.12.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var notesArray: [Note] = []
    var notesDatabaseArray: [NoteObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstLaunchCheck()
        self.offlineLoad()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new note?", message: "Enter note name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { _ in
            guard let name = alert.textFields?.first?.text else { return }
            let noteObject = Note(name: name, text: "", image: "")
            self.notesArray.insert(noteObject, at: 0)
            self.deleteObjectNotes()
            for element in self.notesArray {
                self.saveObjectNotes(object: element)
            }
            DispatchQueue.main.async {
                UIView.transition(with: self.mainTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.mainTableView.reloadData()}, completion: nil)
            }
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addTextField { textField in
            textField.placeholder = "Enter here..."
        }
        present(alert, animated: true, completion: nil)
    }
    
    func saveObjectNotes(object: Note) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "NoteObject", in: context) else { return }
        
        let note = NoteObject(entity: entity, insertInto: context)
        note.name = object.name
        note.text = object.text
        note.image = object.image
        
        do {
            try context.save()
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    func loadObjectNotes() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NoteObject> = NoteObject.fetchRequest()
        
        do {
            notesDatabaseArray = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    func deleteObjectNotes() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NoteObject> = NoteObject.fetchRequest()
        
        if let objects = try? context.fetch(fetchRequest) {
            for object in objects {
                context.delete(object)
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print (error.localizedDescription)
        }
    }
    
    private func offlineLoad() {
        self.loadObjectNotes()
        self.notesArray.removeAll()
        for element in self.notesDatabaseArray {
            let note = Note(name: "", text: "", image: "")
            note.name = element.name
            note.text = element.text
            note.image = element.image
            self.notesArray.append(note)
        }
        self.mainTableView.reloadData()
    }
    
    private func firstLaunchCheck() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            self.notesArray.append(Note(name: "It is your first note!", text: "", image: ""))
            for element in self.notesArray {
                self.saveObjectNotes(object: element)
            }
            DispatchQueue.main.async {
                self.mainTableView.reloadData()
            }
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
}


