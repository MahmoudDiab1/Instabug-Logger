//
//  File.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation

protocol StorageHandler {
    func configure()
    func log(_ level: LogLevel, message: String)
    func fetchAllLogs() -> [Log]
    func fetchAllLogs(completionHandler: @escaping (([Log]) -> Void))
    func fetchAllLogsFormatted () ->[String]
}
 
// (todo): Add different storage options.
public enum StorageType {
    case coreData (limit:Int)
}

extension StorageType {
    var engine:StorageHandler {
        switch self {
        case .coreData(let limit):
            let dataController = DataController(modelName: "LogModel")
            return CoreDataEngine(limit: limit, dataController: dataController)
        }
    }
}

class StorageEngine : StorageHandler {
    
    private var storageEngine:StorageHandler
    
    init(storageType:StorageType) {
        storageEngine = storageType.engine
    }
    
    func configure() {
        storageEngine.configure()
    }
    
    func log(_ level: LogLevel, message: String) {
        storageEngine.log(level , message: message)
    }
    
    func fetchAllLogs() -> [Log]    {
        return  storageEngine.fetchAllLogs() 
    }
    
    func fetchAllLogs(completionHandler:@escaping (([Log]) -> Void)) {
        storageEngine.fetchAllLogs(completionHandler: completionHandler)
    }
    func fetchAllLogsFormatted() -> [String] {
        storageEngine.fetchAllLogsFormatted()
    }
    
}
