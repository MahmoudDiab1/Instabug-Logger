//
//  LogModel.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation
import CoreData

class CoreDataEngine : StorageHandler  {
    
    // MARK: Properties -
    private var dataController:DataController!
    private var backgroundContext : NSManagedObjectContext!
    private var storageCapacity:Int
    
    //MARK: Initializer
    init(limit:Int, dataController:DataController) {
        self.storageCapacity = limit
        dataController.loadPersistenceStore()
        self.dataController  = dataController
        self.backgroundContext = dataController.backGroundContext
    }
    
    // MARK: Configuration -
    func configure() {
        dataController.destroyPersistentStore()
        dataController.loadPersistenceStore()
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
        let semafore = DispatchSemaphore(value: 0)
        var logs = [LogEntity]()
        let request = getFetchRequest()
        request.fetchLimit =  count != nil ? count! : .max
    backgroundContext.perform  {
            if let result = try? self.backgroundContext.fetch(request) {
                logs.append( contentsOf: result)
            }
            semafore.signal()
        }
        semafore.wait()
        return logs
    }
    
    func getFetchRequest() -> NSFetchRequest<LogEntity>{
        let request : NSFetchRequest <LogEntity> = LogEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor (key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    // MARK: Logging -
    
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LogEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        backgroundContext.perform {
            if let result =  try? self.backgroundContext.executeAndMergeChanges(using: batchDeleteRequest) {
                debugPrint(result)
            }
        }
    }
    
    private func decode (_ logs:[LogEntity]) -> [Log]{
        var result:[Log] = []
        for log in logs {
            let decodedLog = Log(level: log.level ?? "", message: log.message ?? "", timeStamp: log.timeStamp ?? Date())
            result.append(decodedLog)
        }
        return result
    }
}

extension CoreDataEngine {
    
    func formatLog(logger: Log ) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
      let formattedDate = dateFormatter.string(from: logger.timeStamp)
        return "\(logger.level.uppercased()): \(formattedDate)    \(logger.message)"
    }
}
