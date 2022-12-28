//
//  ViewController+extensions.swift
//  Notes
//
//  Created by Максим Батрасов on 28.12.2022.
//

import Foundation
import UIKit

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        guard let name = self.notesArray[indexPath.row].name else { return cell }
        cell.configure(text: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "NoteViewController") as? NoteViewController else { return }
        controller.note = self.notesArray[indexPath.row]
        controller.delegate = self
        controller.indexPath = indexPath
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.notesArray.remove(at: indexPath.row)
            self.deleteObjectNotes()
            for element in self.notesArray {
                self.saveObjectNotes(object: element)
            }
            self.mainTableView.beginUpdates()
            self.mainTableView.deleteRows(at: [indexPath], with: .automatic)
            self.mainTableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension ViewController: NoteViewControllerDelegate {
    func backButtonPressed(indexPath: IndexPath, note: Note) {
        self.notesArray[indexPath.row] = note
        self.deleteObjectNotes()
        for element in self.notesArray {
            self.saveObjectNotes(object: element)
        }
        self.mainTableView.reloadData()
    }
}
