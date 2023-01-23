//
//  NoteViewController.swift
//  Notes
//
//  Created by Максим Батрасов on 28.12.2022.
//

import UIKit

protocol NoteViewControllerDelegate: AnyObject {
    func backButtonPressed(indexPath: IndexPath, note: Note)
}

class NoteViewController: UIViewController {
    
    weak var delegate: NoteViewControllerDelegate?
    
    var indexPath: IndexPath?
    
    var note = Note(name: "", text: "", image: "")
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var topTextConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainNavigationItem: UINavigationItem!
    @IBOutlet weak var mainTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainImageView.frame.size.width = self.view.frame.width
        self.mainImageView.layer.cornerRadius = 15
        self.mainNavigationItem.title = note.name
        if let image = note.image {
            if image != "" {
                self.mainImageView.image = self.loadImage(fileName: image)
            }  else {
                self.topTextConstraint.constant -= self.mainImageView.frame.height  /////////////////
            }
        }
        if self.note.text == "" {
            mainTextView.text = "Enter here..."
            mainTextView.textColor = UIColor.lightGray
        } else {
            self.mainTextView.text = note.text
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        if let path = self.indexPath {
            self.delegate?.backButtonPressed(indexPath: path, note: self.note)
        }
    }
    
    @IBAction func editNameButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Edit", message: "Enter note name", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save name", style: .default, handler: { _ in
            self.mainNavigationItem.title = alert.textFields?.first?.text
            self.note.name = alert.textFields?.first?.text
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { alert in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addTextField { textField in
            textField.text = self.note.name
        }
        let imageAlertAction = UIAlertAction(title: "Add image", style: .default, handler: { action in
            switch self.topTextConstraint.constant {
            case 0:
                self.topTextConstraint.constant -= self.mainImageView.frame.height
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.note.image = ""
                    self.mainImageView.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
                }
            default:
                self.topTextConstraint.constant = 0
                self.getImageSelectionAlert()
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        })
        
        switch self.topTextConstraint.constant {
        case 0:
            imageAlertAction.setValue("Delete image", forKeyPath: "title")
        default:
            imageAlertAction.setValue("Add image", forKeyPath: "title")
        }
        
        alert.addAction(imageAlertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func createPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true) {
        }
    }
    
    private func getImageSelectionAlert() {
        let alert = UIAlertController(title: "Please choose source type:", message: "", preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.createPicker(sourceType: .camera)
        }
        let secondAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.createPicker(sourceType: .photoLibrary)
        }
        let thirdAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.topTextConstraint.constant -= self.mainImageView.frame.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(thirdAction)
        present(alert, animated: true, completion: nil)
    }
    
    //Save Image
    
    func saveImage(image: UIImage) -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil} //application folder path
        
        let fileName = UUID().uuidString //unical identifier
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.pngData() else {return nil}
        
        //check if file exists, removes it if so
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print ("Removed old image")
            } catch let error {
                print ("couldn't remove file at path", error)
            }
        }
        
        do {
            try data.write(to: fileURL)
            return fileName
        } catch let error {
            print("error saving file with error", error)
            return nil
        }
    }
    
    //Load Image
    
    func loadImage(fileName: String) -> UIImage? {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imageURL = documentDirectory.appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageURL.path)
            return image
        }
        return nil
    }
}
