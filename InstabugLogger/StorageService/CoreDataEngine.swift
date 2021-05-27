//
//  LogModel.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation
import CoreData

class CoreDataEngine : StorageHandler {
    
    // MARK: Properties -
    private var dataController:DataController!
    private weak var backgroundContext : NSManagedObjectContext!
    private let model = "LogModel"
    
    // MARK: Configuration -
    func configure() {
        let dataController = DataController(modelName: model)
        dataController.loadPersistenceStore()
        self.dataController = dataController
        self.backgroundContext = dataController.backGroundContext
        ///Clean disk store on every app launch.
        deleteAllLogs()
    }
    
    // MARK: Logging -
    /// The logging framework should store each log with it's level and timestamp.
    func log(_ level: LogLevel, message: String) {
            let adapter = LogAdapter(level: level, message: message)
            adapter.adapt(dataController: self.dataController)
            ///  The limit of storage at disk is 1000; if more than 1000 logs received, you should start deleting the earliest logs.
            let logs = self.fetchLogs()
            if logs.count>1000 { self.deleteLog(logToDelete: logs.last!) }
        if let result =   try? dataController.viewContext.saveIfNeeded(){
                print(result)
        }
    }
    
    //MARK: Fetch Logs -
    
    func fetchAllLogs() -> [Log] {
        let request : NSFetchRequest <LogEntity> = LogEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor (key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        if let result = try? dataController.viewContext.fetch(request) {
            return decode(result)
        }
        return []
    }
    
    func fetchAllLogs(completionHandler:@escaping (([Log]) -> Void)) {
            let request : NSFetchRequest <LogEntity> = LogEntity.fetchRequest()
            let sortDescriptor = NSSortDescriptor (key: "timeStamp", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            if let result = try?
                dataController.viewContext.fetch(request) {
                return completionHandler(self.decode(result))
       
        }
    }
    
    func fetchLogs (count:Int? = nil) -> [LogEntity] {
            let request : NSFetchRequest <LogEntity> = LogEntity.fetchRequest()
            let sortDescriptor = NSSortDescriptor (key: "timeStamp", ascending: false)
            request.sortDescriptors = [sortDescriptor]
            request.fetchLimit =  count != nil ? count! : .max
        if let result = try? dataController.viewContext.fetch(request) {
                return result
            }
        return []
    }
    
    //MARK: Delete logs -
    func deleteLog(logToDelete:LogEntity) {
        dataController.viewContext.delete(logToDelete)
        if let result = try? dataController.viewContext.saveIfNeeded() {
            debugPrint(result)
        }
    }
    
    func deleteAllLogs () {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = LogEntity.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        if let result =  try? dataController.viewContext.executeAndMergeChanges(using: batchDeleteRequest) {
                debugPrint(result)
            }
    }
    
    //MARK: Decode from  NSManagedObject to Log. -
  private func decode (_ logs:[LogEntity]) -> [Log]{
        var result:[Log] = []
        for log in logs {
            let decodedLog = Log(level: log.level ?? "", message: log.message ?? "", timeStamp: log.timeStamp ?? Date())
            result.append(decodedLog)
        }
        return result
    }
}
