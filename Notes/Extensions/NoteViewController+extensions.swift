//
//  NoteViewController+extensions.swift
//  Notes
//
//  Created by Максим Батрасов on 28.12.2022.
//

import Foundation
import UIKit

extension NoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var choosenImage = UIImage()
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            choosenImage = image
        } else {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                choosenImage = image
            }
        }
        self.mainImageView.image = choosenImage
        self.note.image = self.saveImage(image: choosenImage)
        
        dismiss(animated: true, completion: nil)
    }
}

extension NoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        self.note.text = textView.text
    }
}
