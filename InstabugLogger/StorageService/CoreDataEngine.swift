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
    
    // MARK: Properties -
    private var coreDataStack:CoreDataStack!
    private var backgroundContext : NSManagedObjectContext!
    private var viewContext : NSManagedObjectContext
    private var storageCapacity:Int
    
    //MARK: Initializer
    init(limit:Int, coreDataStack:CoreDataStack) {
        self.storageCapacity = limit
        self.coreDataStack  = coreDataStack
        self.backgroundContext = coreDataStack.backGroundContext
        self.viewContext = coreDataStack.viewContext
    }
    
    // MARK: Configuration -
    
    ///Called to destroy then load the persistence store as a basic core data stack configuration and InstabugLogger requirement.
    func configure() {
        coreDataStack.destroyPersistentStore()
        coreDataStack.loadPersistenceStore()
    }
    
    //MARK: Fetch Logs -
    func fetchAllLogs() -> [Log]  {
        return decode(fetchLogs())
    }
    
    func fetchAllLogs(completionHandler:@escaping (([Log]) -> Void)) {
        let request = self.getFetchRequest()
        backgroundContext.performAndWait {
            if let result = try?
                self.backgroundContext.fetch(request) {
                completionHandler(self.decode(result))
            }
        }
    }
    
    func fetchAllLogsFormatted() -> [String] {
        return  fetchAllLogs().map{formatLog(logger:$0)}
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
    
    
    // MARK: Insert Logs -
    
    func log(_ level: LogLevel, message: String) {
        let logItem = LogAdapter(level: level, message: message).adapt() 
        let log = LogEntity(context:backgroundContext)
        log.message = logItem.message
        log.level = logItem.level
        log.timeStamp = logItem.timeStamp
        let logs = self.fetchLogs()
        if logs.count>storageCapacity { self.deleteLog(logToDelete: logs.last!) }
        
        backgroundContext.performAndWait {
            if let result =   try? self.backgroundContext.saveIfNeeded(){
                debugPrint(result.description)
            }
        }
    }
    
    //MARK: Delete logs -
    func deleteLog(logToDelete:LogEntity) {
        backgroundContext.perform {
            self.backgroundContext.delete(logToDelete)
            if let result = try? self.backgroundContext.saveIfNeeded() {
                debugPrint(result)
            }
        }
    }
    
    func deleteAllLogs () {
        coreDataStack.destroyPersistentStore()
    }
 
}
//MARK: CoreDataEngine extension -

extension CoreDataEngine {
    
    func getFetchRequest() -> NSFetchRequest<LogEntity>{
        let request : NSFetchRequest <LogEntity> = LogEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor (key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    //Convert from LogEntity model to Log model.
    private func decode (_ logs:[LogEntity]) -> [Log]{
        var result:[Log] = []
        for log in logs {
            let decodedLog = Log(level: log.level ?? "", message: log.message ?? "", timeStamp: log.timeStamp ?? Date())
            result.append(decodedLog)
        }
        return result
    }
    
    func formatLog(logger: Log ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
        let formattedDate = dateFormatter.string(from: logger.timeStamp)
        return "| \(logger.level.uppercased()): \(formattedDate)   \(logger.message) |"
    }
}
