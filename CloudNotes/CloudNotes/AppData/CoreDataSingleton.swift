import UIKit
import CoreData

class CoreDataSingleton {
    static let shared = CoreDataSingleton()
    
    private init() { }
    
    lazy var memoData: [NSManagedObject] = {
        return self.fetch()
    }()
    
    func fetch() -> [NSManagedObject] {
        var fetchData: [NSManagedObject] = [NSManagedObject]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return [NSManagedObject]()
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        let sort = NSSortDescriptor(key: "lastModified", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            if let result: [NSManagedObject] = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                fetchData = result
            }
        } catch {
            print(MemoAppError.system.message)
        }
        return fetchData
    }
    
    func save(title: String, body: String) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw MemoAppError.system
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: managedContext)
        object.setValue(title, forKey: "title")
        object.setValue(body, forKey: "body")
        object.setValue(Date(), forKey: "lastModified")
        
        do {
            try managedContext.save()
            self.memoData.insert(object, at: 0)
        } catch {
            managedContext.rollback()
            print(MemoAppError.system.message)
        }
    }
    
    func delete(object: NSManagedObject) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw MemoAppError.system
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        managedContext.delete(object)
        
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
            print(MemoAppError.system.message)
        }
    }
    
    func update(object: NSManagedObject, title: String, body: String) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            throw MemoAppError.system
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        object.setValue(title, forKey: "title")
        object.setValue(body, forKey: "body")
        object.setValue(Date(), forKey: "lastModified")
        
        do {
            try managedContext.save()
        } catch {
            managedContext.rollback()
            print(MemoAppError.system.message)
        }
    }
}
