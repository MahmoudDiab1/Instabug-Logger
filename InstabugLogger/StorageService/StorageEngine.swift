//
//  File.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation



//MARK: - Storage Types -
/// Storage Types are  storage  options to store user logs at disc..
/// User can select one of them as a basic configuration .

public enum StorageType {
    /// (todo): Add different storage options.
    case coreData
}

public struct StorageConfiguration{
      var  storageType:StorageType
      var limit:Int
    public init(storageType:StorageType, limit:Int) {
        self.storageType = storageType
        self.limit = limit
    }
}

//MARK: - Storage Handler -
/// Storage Handler protocol abstracts the storage read / write operations.
protocol StorageHandler {
    func configure()
    func log(_ level: LogLevel, message: String)
    func fetchAllLogs() -> [Log]
    func fetchAllLogs(completionHandler: @escaping (([Log]) -> Void))
    func fetchAllLogsFormatted () ->[String]
    func deleteAllLogs()
}

//MARK: Storage Engine -
/// StorageEngine  handles storage (read / write) operations.
/// Responsibility: Composing  different types of storage services like CoreDataEngine.

class StorageEngine {

    private var storageType:StorageType
    // Composing CoreDataEngine dependency
    private var coreDataEngine:CoreDataEngine
    
    init(configuration:StorageConfiguration) {
        self.storageType = configuration.storageType
        
        switch storageType {
        case .coreData :
            let modelName = "LogModel" 
            coreDataEngine = CoreDataEngine(limit: configuration.limit, coreDataStack:  CoreDataStack(modelName: modelName))
        }
    }
}

//MARK: Storage Engine extension -
extension StorageEngine : StorageHandler {
    func configure() {
        switch storageType {
        case .coreData :
            coreDataEngine.configure()
        }
    }
    
    func log(_ level: LogLevel, message: String) {
        switch storageType {
        case .coreData :
            coreDataEngine.log(level , message: message)
        }
    }
    
    func fetchAllLogs() -> [Log]    {
        switch storageType {
        case .coreData :
            return  coreDataEngine.fetchAllLogs()
        }
    }
    
    func fetchAllLogs(completionHandler:@escaping (([Log]) -> Void)) {
        switch storageType {
        case .coreData :
            coreDataEngine.fetchAllLogs(completionHandler: completionHandler)
        }
    }
    
    func fetchAllLogsFormatted() -> [String] {
        switch storageType {
        case .coreData :
            return  coreDataEngine.fetchAllLogsFormatted()
        }
    }
    
    func deleteAllLogs() {
        switch storageType {
        case .coreData :
            coreDataEngine.deleteAllLogs()
        }
    }
}
