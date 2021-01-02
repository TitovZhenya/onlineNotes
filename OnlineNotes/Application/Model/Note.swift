import UIKit

struct Note {
    var text: String?
    var noteWidth: CGFloat?
    var noteHeight: CGFloat?
    var activeItemRadius = NoteConstants.ACTIVE_ITEM_RADIUS
    var activeItemWidth = NoteConstants.ACTIVE_ITEM_WIDTH
    var activeItemHeight = NoteConstants.ACTIVE_ITEM_HEIGHT
    var noteView: UIView?
    var textView: UITextView?
    var deleteBtn: UIButton?
    var yellowBtn: UIButton?
    var blueBtn: UIButton?
    var pinkBtn: UIButton?
    var uid: String?
}
