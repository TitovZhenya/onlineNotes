import UIKit
import Firebase

class NotesViewController: UIViewController {
    
    var note: Note?
    var notes: [Note] = []
    var fontSlider = FontSlider()
    var currentTextEdit: UITextView?
    var notePosition: CGPoint?
    var isNoteEditing = false
    var ref: DatabaseReference!
    var currentNoteId: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference(withPath: "notes")
        self.tapCheck()
        self.addUISlider()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.childAdded) { (DataSnapshot) in
            self.loadData(snapshot: DataSnapshot)
        }
        
        ref.observe(.childRemoved) { (DataSnapshot) in
            self.removeData(snapshot: DataSnapshot)
        }
        
        ref.observe(.childChanged) { [weak self] (DataSnapshot) in
            self!.updateData(snapshot: DataSnapshot)
        }
    }
    
    private func removeData(snapshot: DataSnapshot){
        for (index, note) in notes.enumerated() {
            if snapshot.key == note.uid{
                note.noteView!.removeFromSuperview()
                self.notes.remove(at: index)
            }
        }
    }
    
    private func updateData(snapshot: DataSnapshot){
        let data = snapshot.value as! [String:Any]

        let x = data["posX"] as! CGFloat
        let y = data["posY"] as! CGFloat
        let width = data["width"] as! CGFloat
        let height = data["height"] as! CGFloat
        let color = data["color"] as! String
        let fontSize = data["fontSize"] as? CGFloat ?? 10
        let text = data["text"] as? String
                            
        for note in notes{
            if snapshot.key == note.uid{
                note.noteView!.frame = CGRect(x: x,
                                              y: y,
                                              width: width,
                                              height: height)
                guard let textView = note.textView else { return }
                let backgroundColor = self.updateBgc(color: color)
                note.noteView!.backgroundColor = backgroundColor
                textView.text = text
                textView.font = .systemFont(ofSize: fontSize)
                return
            }
        }
    }
    
    private func loadData(snapshot: DataSnapshot){
        for note in notes {
            if snapshot.key == note.uid{
                return
            }
        }
        let data = snapshot.value as! [String:Any]

        let x = data["posX"] as! CGFloat
        let y = data["posY"] as! CGFloat
        let width = data["width"] as! CGFloat
        let height = data["height"] as! CGFloat
        let color = data["color"] as! String
        let fontSize = data["fontSize"] as? CGFloat ?? 10
        let text = data["text"] as? String


        self.note = Note()
        let noteView = self.createNoteView(x: x, y: y, width: width, height: height)
        let backgroundColor = self.updateBgc(color: color)
        noteView.backgroundColor = backgroundColor
        self.view.addSubview(noteView)
        self.createTextView(view: noteView, marginTop: note!.activeItemWidth)
        note?.textView?.text = text
        note?.textView?.font = .systemFont(ofSize: fontSize)
        self.addColorChanger(view: noteView, width: note!.activeItemWidth,
                             height: note!.activeItemHeight, radius: note!.activeItemRadius,
                             color: .yellow, spacingX: note!.activeItemWidth * 0.5, tag: 1)
        self.addColorChanger(view: noteView, width: note!.activeItemWidth,
                             height: note!.activeItemHeight, radius: note!.activeItemRadius,
                             color: .systemPink, spacingX: note!.activeItemWidth * 1.5, tag: 2)
        self.addColorChanger(view: noteView, width: note!.activeItemWidth,
                             height: note!.activeItemHeight, radius: note!.activeItemRadius,
                             color: .blue, spacingX: note!.activeItemWidth * 2.5, tag: 3)
        self.addDeleteBtn(view: noteView, width: note!.activeItemWidth, height: note!.activeItemHeight, radius: note!.activeItemRadius)
        self.addResizeBtn(view: noteView, width: note!.activeItemWidth, height: note!.activeItemHeight)
        self.addPanForMove(view: noteView)
        self.bringUpView(view: noteView)
        self.note!.uid = snapshot.key
        notes.append(self.note!)
    }
    
    private func tapCheck() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addNote))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func addNote(sender: UITapGestureRecognizer) {
        if isNoteEditing == false {
            self.note = Note()
            self.note!.noteWidth = self.view.frame.width / 2
            self.note!.noteHeight = self.view.frame.height / 6
            
            guard let noteWidth = note?.noteWidth,
                  let noteHeight = note?.noteHeight,
                  let activeItemWidth = note?.activeItemWidth,
                  let activeItemHeight = note?.activeItemHeight,
                  let activeItemRadius = note?.activeItemRadius
            else { return }
            
            let touchLocation = sender.location(in: self.view)
            let pointX = touchLocation.x - noteWidth / 2
            let pointY = touchLocation.y - noteHeight / 2
            let noteView = createNoteView(x: pointX, y: pointY,
                                       width: noteWidth, height: noteHeight)
            
            self.view.addSubview(noteView)
            self.createTextView(view: noteView, marginTop: activeItemWidth)
            
            
            self.addColorChanger(view: noteView, width: activeItemWidth,
                               height: activeItemHeight, radius: activeItemRadius,
                               color: .yellow, spacingX: activeItemWidth * 0.5, tag: 1)
            self.addColorChanger(view: noteView, width: activeItemWidth,
                               height: activeItemHeight, radius: activeItemRadius,
                               color: .systemPink, spacingX: activeItemWidth * 1.5, tag: 2)
            self.addColorChanger(view: noteView, width: activeItemWidth,
                               height: activeItemHeight, radius: activeItemRadius,
                               color: .blue, spacingX: activeItemWidth * 2.5, tag: 3)
            
            self.addDeleteBtn(view: noteView, width: activeItemWidth, height: activeItemHeight, radius: activeItemRadius)
            self.addResizeBtn(view: noteView, width: activeItemWidth, height: activeItemHeight)
            self.addPanForMove(view: noteView)
            self.bringUpView(view: noteView)
            
            let uid = UUID().uuidString
            self.note!.uid = uid
            addToFireBase(view: noteView, uid: uid)
            notes.append(self.note!)
        }
    }
    
    private func createNoteView(x: CGFloat, y: CGFloat,
                             width: CGFloat, height: CGFloat) -> UIView{
        let noteView = UIView()
        noteView.backgroundColor = .yellow
        noteView.frame = CGRect(x: x, y: y,
                                width: width, height: height)
        noteView.layer.borderColor = UIColor.black.cgColor
        noteView.layer.borderWidth = 1
        self.note!.noteView = noteView
        return noteView
    }
    
    private func createTextView(view: UIView, marginTop: CGFloat){
        let textView = UITextView()
        textView.allowsEditingTextAttributes = true
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        
        view.addSubview(textView)
        self.addKeyboardButton(view: textView)
        textView.tag = notes.count
        
        self.note!.textView = textView
        
        NSLayoutConstraint(item: textView,
                           attribute: .trailingMargin,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .trailingMargin,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: textView,
                           attribute: .leading,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .leading,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: textView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .topMargin,
                           multiplier: 1,
                           constant: marginTop).isActive = true
        NSLayoutConstraint(item: textView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .bottomMargin,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    private func addKeyboardButton(view: UITextView) {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolBar.barStyle = .default
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        
        let doneButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(self.doneButtonAction))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        view.inputAccessoryView = toolBar
    }
    
    @objc
    private func doneButtonAction () {
        view.endEditing(false)
    }
    
    private func addColorChanger(view: UIView, width: CGFloat,
                                    height: CGFloat, radius: CGFloat,
                                    color: UIColor, spacingX: CGFloat,
                                    tag: Int){
        let posX = view.bounds.origin.x + spacingX
        let posY = view.bounds.origin.y + 5
        let button = UIButton(frame: CGRect(x: posX,
                                               y: posY,
                                               width: width,
                                               height: height))

        button.backgroundColor = color
        button.layer.cornerRadius = radius
        button.alpha = 0
        button.tag = tag
        view.addSubview(button)

        button.addTarget(self, action: #selector(switchBGColor), for: .touchUpInside)
        switch color {
        case .yellow:
            self.note!.yellowBtn = button
        case .systemPink:
            self.note!.pinkBtn = button
        case .blue:
            self.note!.blueBtn = button
        default:
            self.note!.yellowBtn = button
        }
    }
    
    @objc
    private func switchBGColor(sender: UIButton) {
        for note in notes {
            guard let noteView = note.noteView else { return }
            if sender.isDescendant(of: noteView) {
                guard let id = note.uid else {
                    return
                }
                switch sender.tag {
                case 1:
                    noteView.backgroundColor = .yellow
                    ref.child(id).updateChildValues(["color" : "yellow"])
                case 2:
                    noteView.backgroundColor = .systemPink
                    ref.child(id).updateChildValues(["color" : "pink"])
                case 3:
                    noteView.backgroundColor = .blue
                    ref.child(id).updateChildValues(["color" : "blue"])
                default:
                    noteView.backgroundColor = .yellow
                    ref.child(id).updateChildValues(["color" : "yellow"])
                }
            }
        }
    }
    
    private func addDeleteBtn(view: UIView, width: CGFloat, height: CGFloat, radius: CGFloat) {
        let deleteBtn = UIButton()
        deleteBtn.translatesAutoresizingMaskIntoConstraints = false
        deleteBtn.layer.cornerRadius = radius
        deleteBtn.alpha = 0
        view.addSubview(deleteBtn)
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageView.image = UIImage(named: "Delete")
        imageView.contentMode = .scaleToFill
        deleteBtn.addSubview(imageView)
        deleteBtn.tag = notes.count
        deleteBtn.addTarget(self, action: #selector(deleteNote), for: .touchUpInside)
        self.note!.deleteBtn = deleteBtn
        
        NSLayoutConstraint(item: deleteBtn,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: -5).isActive = true
        NSLayoutConstraint(item: deleteBtn,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .top,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint(item: deleteBtn,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: height).isActive = true
        NSLayoutConstraint(item: deleteBtn,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: width).isActive = true
            }
    
    @objc
    private func deleteNote(sender: UIButton) {
        for (index, note) in notes.enumerated() {
            guard let noteView = note.noteView else { return }
            if sender.isDescendant(of: noteView) {
                noteView.removeFromSuperview()
                notes.remove(at: index)
                guard let id = note.uid else {
                    return
                }
                ref.child(id).removeValue()
            }
        }
    }
    
    private func addResizeBtn(view: UIView, width: CGFloat, height: CGFloat) {
        let resizeBtn = UIButton()
        resizeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resizeBtn)
        resizeBtn.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let tap = UIPanGestureRecognizer(target: self, action: #selector(resize))
        resizeBtn.addGestureRecognizer(tap)
        
        NSLayoutConstraint(item: resizeBtn,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: resizeBtn,
                           attribute: .trailing,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .trailing,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: resizeBtn,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .height,
                           multiplier: 1,
                           constant: height).isActive = true
        NSLayoutConstraint(item: resizeBtn,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .width,
                           multiplier: 1,
                           constant: width).isActive = true
    }
    
    @objc
    private func resize(sender: UIPanGestureRecognizer) {
        guard let panView = sender.view else { return }
        for note in notes {
            guard let noteView = note.noteView else { return }
            if panView.isDescendant(of: noteView) {
                guard let id = note.uid else {
                    return
                }
                let point = sender.location(in: noteView)
                if point.x >= 100 && point.y >= 80 {
                    noteView.frame = CGRect(x: noteView.frame.origin.x,
                                            y: noteView.frame.origin.y,
                                            width: point.x,
                                            height: point.y)
                    panView.frame.origin.x = point.x - 20
                    panView.frame.origin.y = point.y - 20
                    let width = noteView.frame.width
                    let height = noteView.frame.height
                    ref.child(id).updateChildValues(["width" : width, "height" : height])
                }
            }
        }
    }
    
    private func bringUpView(view: UIView){
        let tap = UITapGestureRecognizer(target: self, action: #selector(bringUp))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    private func bringUp(sender: UITapGestureRecognizer){
        guard let tapView = sender.view else { return }
        for note in notes {
            guard let noteView = note.noteView else { return }
            if tapView.isDescendant(of: noteView){
                self.view.bringSubviewToFront(noteView)
            }
        }
    }
    
    private func addPanForMove(view: UIView){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveNote))
        view.addGestureRecognizer(pan)
    }
    
    @objc
    private func moveNote(sender: UIPanGestureRecognizer){
        guard let onPanView = sender.view else { return }
        for note in notes {
            guard let noteView = note.noteView else { return }
            if onPanView.isDescendant(of: noteView){
                self.view.bringSubviewToFront(noteView)
                let translation = sender.translation(in: self.view)
                let posX = noteView.center.x + translation.x
                let posY = noteView.center.y + translation.y
                noteView.center = CGPoint(x: posX, y: posY)
                sender.setTranslation(.zero, in: self.view)
                guard let id = note.uid else {
                    return
                }
                ref.child(id).updateChildValues(["posX" : noteView.frame.origin.x, "posY" : noteView.frame.origin.y])
            }
        }
    }
    
    func addUISlider(){
        let screenSize = UIScreen.main.bounds
        let sliderWidth = self.view.frame.width / 2
        let slider = UISlider(frame: CGRect(x: screenSize.width / 2 - sliderWidth / 2,
                                            y: 70,
                                            width: sliderWidth,
                                            height: 23))
        slider.minimumValue = 5
        slider.maximumValue = 25
        slider.value = 10
        slider.alpha = 0
        self.view.addSubview(slider)
        slider.addTarget(self, action: #selector(changeFontSize), for: .valueChanged)
        
        let fontLabel = UILabel(frame: CGRect(x: 0 ,
                                              y: 40,
                                              width: screenSize.width,
                                              height: 23))
        fontLabel.textAlignment = .center
        fontLabel.alpha = 0
        fontLabel.textColor = .black
        self.view.addSubview(fontLabel)
        self.fontSlider.fontText = fontLabel
        self.fontSlider.slider = slider
    }
    
    @objc
    private func changeFontSize(sender: UISlider){
        let fontSize = Int(sender.value)
        currentTextEdit?.font = .systemFont(ofSize: CGFloat(fontSize))
        self.fontSlider.fontText?.text = "Font: \(fontSize)"
        guard let id = currentNoteId else { return }
        ref.child(id).updateChildValues(["fontSize" : fontSize])
        
    }
    
    private func addToFireBase(view: UIView, uid: String){
        let posX = view.frame.origin.x
        let posY = view.frame.origin.y
        let width = view.frame.width
        let height = view.frame.height
        let fontSize = 10
        let color = "yellow"

        let noteRef = self.ref.child(uid)
        noteRef.setValue(["posX" : posX,
                          "posY" : posY,
                          "width" : width,
                          "height" : height,
                          "fontSize" : fontSize,
                          "color" : color])
    }
    
    private func updateBgc(color: String) -> UIColor{
        let backgroundColor: UIColor
        switch color {
        case "yellow":
            backgroundColor = UIColor.yellow
        case "pink":
            backgroundColor = UIColor.systemPink
        case "blue":
            backgroundColor = UIColor.blue
        default:
            backgroundColor = UIColor.yellow
        }
        return backgroundColor
    }
}

