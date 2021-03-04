import UIKit
import SwiftyDropbox

protocol TableViewListManagable: class {
    func updateTableViewList()
    func deleteCell()
    func moveCellToTop()
}

class MemoListTableViewController: UITableViewController {
    let client = DropboxClientsManager.authorizedClient
    
    private let enrollButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isCellSelected.rawValue)
        tableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: "MemoCell")
        
        loginDropbox()
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
        let memo = CoreDataSingleton.shared.memoData[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell") as? MemoListTableViewCell else {
            return UITableViewCell()
        }

        cell.receiveLabelsText(memo: memo)
        return cell
    }
    
    @objc func createMemo(sender: UIButton) {
        do {
            try CoreDataSingleton.shared.save(title: "", body: "")
            showContentsViewController(index: 0)
            tableView.reloadData()
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isCellSelected.rawValue)
        } catch {
            print(MemoAppError.system.message)
        }
    }
    
    private func showContentsViewController(index: Int) {
        let memoContentsViewController = MemoContentsViewController()
        let memoContentsNavigationViewController = UINavigationController(rootViewController: memoContentsViewController)
        memoContentsViewController.receiveText(memo: CoreDataSingleton.shared.memoData[index])
        memoContentsViewController.delegate = self
        
        self.splitViewController?.showDetailViewController(memoContentsNavigationViewController, sender: nil)
    }
}

// MARK: UITableViewDelegate
extension MemoListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showContentsViewController(index: indexPath.row)
        
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isCellSelected.rawValue)
        UserDefaults.standard.set(indexPath.row, forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let memoContentsView = MemoContentsViewController()
        if editingStyle == .delete {
            let selectedMemoIndexPathRow = UserDefaults.standard.integer(forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
            
            do {
                try CoreDataSingleton.shared.delete(object: CoreDataSingleton.shared.memoData[selectedMemoIndexPathRow])
                CoreDataSingleton.shared.memoData.remove(at: selectedMemoIndexPathRow)
                UserDefaults.standard.set(0, forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if splitViewController?.traitCollection.horizontalSizeClass == .regular {
                    switch CoreDataSingleton.shared.memoData.isEmpty {
                    case false:
                        memoContentsView.receiveText(memo: CoreDataSingleton.shared.memoData[0])
                        self.splitViewController?.showDetailViewController(memoContentsView, sender: nil)
                    case true:
                        splitViewController?.viewControllers.removeLast()
                    }
                }
            } catch {
                print(MemoAppError.system.message)
            }
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

// MARK: TableViewListManagable
extension MemoListTableViewController: TableViewListManagable {
    func updateTableViewList() {
        tableView.reloadData()
    }
    
    func deleteCell() {
        let selectedMemoIndexPathRow = UserDefaults.standard.integer(forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
        let indexPath = IndexPath(row: selectedMemoIndexPathRow, section: 0)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
    }
    
    func moveCellToTop() {
        if UserDefaults.standard.value(forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue) as? Int == 0 {
            return
        }
        
        let selectedMemoIndexPathRow = UserDefaults.standard.integer(forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
        let indexPath = IndexPath(row: selectedMemoIndexPathRow, section: 0)
        let firstIndexPath = IndexPath(item: 0, section: 0)
        
        let memo = CoreDataSingleton.shared.memoData.remove(at: selectedMemoIndexPathRow)
        CoreDataSingleton.shared.memoData.insert(memo, at: 0)
        
        self.tableView.moveRow(at: indexPath, to: firstIndexPath)
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.selectedMemoIndexPathRow.rawValue)
    }
}

extension MemoListTableViewController {
    func loginDropbox() {
      let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read"], includeGrantedScopes: false)
        
      DropboxClientsManager.authorizeFromControllerV2(
          UIApplication.shared,
          controller: self,
          loadingStatusDelegate: nil,
        openURL: { (url: URL) -> Void in UIApplication.shared.open(url) },
          scopeRequest: scopeRequest
      )
    }
    
    func uploadDropbox() {
        let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!

        let request = client?.files.upload(path: "Users/chanwoo/Library/Developer/CoreSimulator/Devices/79751B1A-FDC8-4F9E-99A0-8734F6B3E6CD/data/Containers/Data/Application/5DF01620-9F8B-4920-BB22-82B23377FFC4/Documents/", input: fileData)
            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
}
