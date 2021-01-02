import UIKit

extension NotesViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.currentTextEdit = textView
        self.isNoteEditing = true
        for note in notes {
            guard let noteView = note.noteView else { return }
            if textView.isDescendant(of: noteView){
                self.currentNoteId = note.uid
                self.view.bringSubviewToFront(noteView)
                let position = CGPoint(x: noteView.frame.origin.x,
                                       y: noteView.frame.origin.y)
                self.notePosition = position
                
                let posX = (self.view.frame.size.width - noteView.frame.size.width) / 2
                let posY = self.view.frame.height / 5
                
                let textSize = Int(textView.font?.pointSize ?? 10)
                guard let slider = fontSlider.slider,
                      let fontText = fontSlider.fontText else {
                    return
                }
                
                slider.value = Float(textSize)
                fontText.text = "Font: \(textSize)"
                
                self.view.bringSubviewToFront(slider)
                self.view.bringSubviewToFront(fontText)
                UIView.animate(withDuration: 0.5) {
                    note.yellowBtn?.alpha = 1
                    note.blueBtn?.alpha = 1
                    note.pinkBtn?.alpha = 1
                    note.deleteBtn?.alpha = 1
                    self.fontSlider.slider?.alpha = 1
                    self.fontSlider.fontText?.alpha = 1
                }
                guard let id = note.uid else {
                    return
                }
                noteView.frame.origin.x = posX
                noteView.frame.origin.y = posY
                self.ref.child(id).updateChildValues(["posX" : posX,
                                                      "posY" : posY])
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        for note in notes {
            self.isNoteEditing = false
            guard let noteView = note.noteView else { return }
            if textView.isDescendant(of: noteView){
                guard let x = self.notePosition?.x,
                      let y = self.notePosition?.y
                else { return }
                let posX = x
                let posY = y
                
                UIView.animate(withDuration: 0.5) {
                    note.yellowBtn?.alpha = 0
                    note.blueBtn?.alpha = 0
                    note.pinkBtn?.alpha = 0
                    note.deleteBtn?.alpha = 0
                    self.fontSlider.slider?.alpha = 0
                    self.fontSlider.fontText?.alpha = 0
                }
                guard let id = note.uid else { return }
                noteView.frame.origin.x = posX
                noteView.frame.origin.y = posY
                ref.child(id).updateChildValues(["posX" : posX,
                                                 "posY" : posY])
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        for note in notes {
            guard let noteView = note.noteView else { return }
            if textView.isDescendant(of: noteView){
                
                
                guard let id = note.uid,
                      let text = textView.text else { return }
                ref.child(id).updateChildValues(["text" : text])
            }
        }
    }
}
