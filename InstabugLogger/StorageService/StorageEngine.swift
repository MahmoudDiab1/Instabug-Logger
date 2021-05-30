//
//  File.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation  

//MARK:- Storage Types -
/// Storage Type contains  storage  options to store logs locally at disk.
/// User can select one of them as a custom configuration .

public enum StorageType {
    /// (todo): Add different storage options.
    case coreData
}


//MARK:- Storage Configuration -
///Custom configuration module to configure the storage option and limit.

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

//MARK: - Storage Engine -
/// StorageEngine  handles storage (read / write) operations based on storage type.

class StorageEngine {
    private var storageHandler:StorageHandler
    init(configuration:StorageConfiguration) {
        switch configuration.storageType {
        case .coreData:
            storageHandler = CoreDataEngine(limit: configuration.limit, coreDataStack:  CoreDataStack(modelName: "LogModel"))
        }
    }
}

//MARK: Storage Engine extension -
extension StorageEngine : StorageHandler {
    
    func configure() {
        storageHandler.configure()
    }
    
    func log(_ level: LogLevel, message: String) {
        storageHandler.log(level , message: message)
    }
    
    func fetchAllLogs() -> [Log]    {
        return  storageHandler.fetchAllLogs()
    }
    
    func fetchAllLogs(completionHandler:@escaping (([Log]) -> Void)) {
        storageHandler.fetchAllLogs(completionHandler: completionHandler)
    }
    
    func fetchAllLogsFormatted() -> [String] {
        return  storageHandler.fetchAllLogsFormatted()
    }
    
    func deleteAllLogs() {
        storageHandler.deleteAllLogs()
    }
}
