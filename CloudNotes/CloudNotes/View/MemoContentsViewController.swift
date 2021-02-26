import UIKit
import CoreData

class MemoContentsViewController: UIViewController {
    private var selectedMemo: Int = 0
    let disclosureButton = UIButton()
    
    private let finishButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(dismissButton))
    
    private var memoTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.adjustsFontForContentSizeCategory = true
        textView.dataDetectorTypes = .all
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMemoContentsView()
        configureAutoLayout()
        configureNavigationBar()
        configureDisclosureButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("ShowTableView"), object: nil)
    }
    
    private func configureDisclosureButton() {
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        disclosureButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        disclosureButton.addTarget(self, action: #selector(showActionSheet(_:)), for: .touchUpInside)
    }
    
    private func configureNavigationBar() {
        let disclosureBarButton = UIBarButtonItem(customView: disclosureButton)
        navigationItem.rightBarButtonItems = [disclosureBarButton]
    }
    
    private func configureMemoContentsView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewDidTapped))
        tapGesture.delegate = self
        
        memoTextView.delegate = self
        memoTextView.isEditable = false
        memoTextView.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = .white
        view.addSubview(memoTextView)
    }
    
    private func configureAutoLayout() {
        NSLayoutConstraint.activate([
            memoTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            memoTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            memoTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            memoTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func receiveText(memo: NSManagedObject) {
        guard let title: String = memo.value(forKey: "title") as? String else {
            return
        }
        guard let memoBody: String = memo.value(forKey: "body") as? String else {
            return
        }
        let body: String = "\n" + memoBody
        let titleFontSize = UIFont.preferredFont(forTextStyle: .largeTitle)
        let bodyFontSize = UIFont.preferredFont(forTextStyle: .body)
        
        let attributedText = NSMutableAttributedString(string: title, attributes: [.font: titleFontSize])
        attributedText.append(NSAttributedString(string: body, attributes: [.font: bodyFontSize]))
        
        memoTextView.attributedText = attributedText
    }
    
    @objc func dismissButton(_ sender: UIButton) {
        memoTextView.resignFirstResponder()
        navigationItem.rightBarButtonItems?.removeFirst()
        memoUpdate()
    }
    
    @objc func showActionSheet(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            self.showActivityView(memo: CoreDataSingleton.shared.memoData[0])
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            (action: UIAlertAction) in self.showDeleteMessage()
        })
        
        actionSheet.addAction(shareAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        actionSheet.popoverPresentationController?.sourceView = disclosureButton
        actionSheet.popoverPresentationController?.sourceRect = disclosureButton.bounds
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func showDeleteMessage() {
        let deleteMenu = UIAlertController(title: "진짜요?", message: "정말로 삭제하시겠어요?", preferredStyle: UIAlertController.Style.alert)
        
        let cancleAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            self.deleteMemo()
        }
        deleteMenu.addAction(cancleAction)
        deleteMenu.addAction(deleteAction)
        
        present(deleteMenu, animated: true, completion: nil)
    }
    
    private func deleteMemo() {
        let indexPath = IndexPath(row: selectedMemo, section: 0)
        
        CoreDataSingleton.shared.delete(object: CoreDataSingleton.shared.memoData[indexPath.row])
        
        CoreDataSingleton.shared.memoData.remove(at: indexPath.row)
        NotificationCenter.default.post(name: NSNotification.Name("deleteCell"), object: nil, userInfo: ["cellIndexNumber": selectedMemo])
        selectedMemo = 0
        
        //        let memoContentsView = MemoContentsViewController()
        self.receiveText(memo: CoreDataSingleton.shared.memoData[0])
        
        //        if UITraitCollection.current.horizontalSizeClass == .regular {
        //            self.splitViewController?.showDetailViewController(memoContentsView, sender: nil)
        //        }
    }
    
    func memoUpdate() {
        let splitText = splitString()
        
        CoreDataSingleton.shared.update(object: CoreDataSingleton.shared.memoData[selectedMemo], title: splitText.0, body: splitText.1)
        NotificationCenter.default.post(name: NSNotification.Name("ShowTableView"), object: nil)
    }
    
    func splitString() -> (String, String) {
        var titleText: String = ""
        var bodyText: String = ""
        
        let arr = memoTextView.text.split(separator: "\n").map { (value) -> String in
            return String(value) }
        
        switch arr.count {
        case 0:
            titleText = ""
            bodyText = ""
        case 1:
            titleText = arr[0]
        default:
            titleText = arr[0]
            for i in 1...(arr.count - 1) {
                bodyText += (arr[i] + "\n")
            }
        }
        return (titleText, bodyText)
    }
}

// MARK: UITextViewDelegate
extension MemoContentsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        memoTextView.isEditable = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        memoUpdate()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            print("enter gogogogo")
        }
        return true
    }
}

// MARK: dataDetectorTypes & isEditable
extension MemoContentsViewController {
    @objc func textViewDidTapped(_ recognizer: UITapGestureRecognizer) {
        if memoTextView.isEditable { return }
        
        guard let textView = recognizer.view as? UITextView else {
            return
        }
        let tappedLocation = recognizer.location(in: textView)
        
        let glyphIndex = textView.layoutManager.glyphIndex(for: tappedLocation, in: textView.textContainer)
        
        if glyphIndex < textView.textStorage.length,
           textView.textStorage.attribute(NSAttributedString.Key.link, at: glyphIndex, effectiveRange: nil) == nil {
            placeCursor(textView, tappedLocation)
            makeTextViewEditable()
            navigationItem.rightBarButtonItems?.insert(finishButton, at: 0)
        }
    }
    
    private func placeCursor(_ myTextView: UITextView, _ location: CGPoint) {
        if let tapPosition = myTextView.closestPosition(to: location) {
            let uiTextRange = myTextView.textRange(from: tapPosition, to: tapPosition)
            
            if let start = uiTextRange?.start, let end = uiTextRange?.end {
                let loc = myTextView.offset(from: myTextView.beginningOfDocument, to: tapPosition)
                let length = myTextView.offset(from: start, to: end)
                myTextView.selectedRange = NSMakeRange(loc, length)
            }
        }
    }
    
    private func makeTextViewEditable() {
        memoTextView.isEditable = true
        memoTextView.becomeFirstResponder()
    }
}

// MARK: UIGestureRecognizerDelegate
extension MemoContentsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: UIActivityViewController
extension MemoContentsViewController {
    @objc func showActivityView(memo: NSManagedObject) {
        guard let title: String = memo.value(forKey: "title") as? String else {
            return
        }
        guard let body: String = memo.value(forKey: "body") as? String else {
            return
        }
        let memoToShare = [title, body]
        let activityViewController = UIActivityViewController(activityItems: memoToShare, applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}
