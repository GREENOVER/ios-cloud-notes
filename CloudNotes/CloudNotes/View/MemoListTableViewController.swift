import UIKit

class MemoListTableViewController: UITableViewController {
    var memoList = [Memo]()
    var isCellSelected: Bool = false
    private let enrollButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: "MemoCell")
  
        NotificationCenter.default.addObserver(self, selector: #selector(changeIsCellSelected), name: NSNotification.Name("ShowTableView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteCell), name: NSNotification.Name(rawValue: "deleteCell"), object: nil)
    }
    
    override init(style: UITableView.Style = .plain) {
        super.init(style: style)
        decodeJSONToMemoList(fileName: "sample")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changeIsCellSelected() {
        isCellSelected = false
        tableView.reloadData()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "메모"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: enrollButton)
        enrollButton.setImage(UIImage(systemName: "plus"), for: .normal)
        enrollButton.addTarget(self, action: #selector(createMemo), for: .touchUpInside)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataSingleton.shared.memoData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        
        let record = CoreDataSingleton.shared.memoData[indexPath.row]
        
        cell.listTitleLabel.text = record.value(forKey: "title") as? String
        cell.listShortBodyLabel.text = record.value(forKey: "body") as? String
//        cell.listLastModifiedDateLabel.text = record.value(forKey: "lastModified") as? Date
        
        return cell
    }
    
    @objc func createMemo(sender: UIButton) {
        CoreDataSingleton.shared.save(title: "테스트", body: "컬러")
        
        let memoContentsView = MemoContentsViewController()
        memoContentsView.receiveText(memo: CoreDataSingleton.shared.memoData[0])
        tableView.reloadData()
        self.splitViewController?.showDetailViewController(memoContentsView, sender: nil)
        
        isCellSelected = true
    }
    
    @objc func deleteCell(_ noti: Notification) {
        guard let index =  noti.userInfo?["cellIndexNumber"] as? Int else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: UITableViewDelegate
extension MemoListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memoContentsViewController = MemoContentsViewController()
        let memoContentsNavigationViewController = UINavigationController(rootViewController: memoContentsViewController)
        
        isCellSelected = true
        memoContentsViewController.receiveText(memo: CoreDataSingleton.shared.memoData[indexPath.row])
        self.splitViewController?.showDetailViewController(memoContentsNavigationViewController, sender: nil)
    }
}

// MARK: JSONDecoding
extension MemoListTableViewController {
    private func decodeJSONToMemoList(fileName: String) {
        guard let dataAsset: NSDataAsset = NSDataAsset.init(name: fileName) else {
            return
        }
        let jsonDecoder: JSONDecoder = JSONDecoder()
        do {
            let decodeData = try jsonDecoder.decode([Memo].self, from: dataAsset.data)
            memoList = decodeData
        } catch {
            showAlertMessage(MemoAppError.system.message)
        }
    }
}

// MARK: Alert
extension MemoListTableViewController {
    private func showAlertMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
