//
//  LogModel.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation
import CoreData

//MARK: Core Data Engine -
///Responsibility: Abstracted service that accepts core data stack object and the storage limit to handle read/write operations on core data

class CoreDataEngine : StorageHandler  {
    
    // MARK: - Properties -
    private var coreDataStack:CoreDataStack!
    private var backgroundContext : NSManagedObjectContext!
    private var viewContext : NSManagedObjectContext
    private var storageLimit:Int
   
    /// The default number of logs to free if reaching the max storage limit.
    /// passing it as a parameter during log insertion is an option to be implemented.
    private var logsToFree : UInt = 1
    
    
    // MARK: Initializer -
    init(limit:Int, coreDataStack:CoreDataStack) {
        self.storageLimit = limit
        self.coreDataStack  = coreDataStack
        self.backgroundContext = coreDataStack.backGroundContext
        self.viewContext = coreDataStack.viewContext
    }
    
    
    // MARK: Insert Log -
    func log(_ level: LogLevel, message: String) {
        if fetchLogs().count >= storageLimit {
            self.freeSpace(numberOfLogs: .someOfLogs(number:  logsToFree ))
        }
        let logItem = LogAdapter(level: level, message: message).adapt()
        let log = LogEntity(context:backgroundContext)
        log.message = logItem.message
        log.level = logItem.level
        log.timeStamp = logItem.timeStamp
        backgroundContext.saveIfNeeded()
    }
    
    // MARK: Configuration -
    /// Called to destroy & load the persistence store as a basic configuration.
    func configure() {
        coreDataStack.destroyPersistentStore()
        coreDataStack.loadPersistenceStore()
    }
}


//MARK: Fetching Logs -
extension CoreDataEngine {
    func fetchAllLogs() -> [Log]  {
        let decodedLogs = fetchLogs()
        return decode(decodedLogs)
    }
    
    func fetchAllLogs(completionHandler:@escaping (([Log]) -> Void)) {
        let request = self.getFetchRequest()
        if let result = try?
            self.backgroundContext.fetch(request) {
            let decodedLogs = self.decode(result)
            completionHandler(decodedLogs)
        }
    }
    
    func fetchAllLogsFormatted() -> [String] {
        let formattedLogs = fetchLogs().map{formatLog(logger:$0)}
        return formattedLogs
    }
    
    private func fetchLogs (count:Int? = nil) -> [LogEntity] {
        var logs = [LogEntity]()
        let request = getFetchRequest()
        request.fetchLimit =  count != nil ? count! : .max
        backgroundContext.performAndWait {
            if let result = try? self.backgroundContext.fetch(request) {
                logs.append( contentsOf: result)
            }
        } 
        return logs
    }
    
    private func getFetchRequest() -> NSFetchRequest<LogEntity>{
        let request : NSFetchRequest <LogEntity> = LogEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor (key: "timeStamp", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
}


//MARK: - Delete logs -

extension CoreDataEngine {
    func deleteAllLogs () {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "LogEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let persistentStoreCoordinator = coreDataStack.persistenceContainer.persistentStoreCoordinator
        backgroundContext.performAndWait {
            _ = try? persistentStoreCoordinator.execute(deleteRequest, with: backgroundContext)
        }
    }
    
    func freeSpace(numberOfLogs: DeletionType) {
        switch numberOfLogs {
        case .allLogs:
            deleteAllLogs ()
        case .someOfLogs(number: let number):
            if number >= storageLimit {
                deleteAllLogs()
            } else {
                deleteLogs(number: number)
            }
        }
    }
    
    private func deleteLogs (logs:[LogEntity]) {
        _ = logs.map { self.backgroundContext.delete($0)}
        self.backgroundContext.saveIfNeeded()
    }
    
    private func deleteLogs (number:UInt) {
        guard number != 0 else {return}
        let logsToDelete = fetchLogs(count: Int( number))
        deleteLogs(logs: logsToDelete)
    }
}

//MARK: Format logs  -
extension CoreDataEngine {
    //Convert from LogEntity model to Log model.
    private func decode (_ logs:[LogEntity]) -> [Log]{
        var result:[Log] = []
        for log in logs {
            let decodedLog = Log(level: log.level , message: log.message , timeStamp: log.timeStamp )
            result.append(decodedLog)
        }
        return result
    }
    
    func formatLog(logger: LogEntity ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        let formattedDate = dateFormatter.string(from: logger.timeStamp )
        return "| \(logger.level.uppercased()): \(formattedDate)   \(logger.message) |"
    }
}
