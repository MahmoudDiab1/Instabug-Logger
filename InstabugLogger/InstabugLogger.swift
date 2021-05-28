//
//  InstabugLogger.swift
//  InstabugLogger
//
//  Created by Yosef Hamza on 19/04/2021.
//

import Foundation
import CoreData  

public class InstabugLogger  {
    
    //MARK: - Properties -
    
    public static var shared : InstabugLogger = InstabugLogger()
    
    private var storageType:StorageType? 
    lazy  var storageService : StorageHandler = {
        let service = StorageEngine(storageType: storageType ?? .coreData(limit: 1000))
        return service
    }()
    
    //MARK: - Configuration -
    
    ///`Configure` function responsible for the basic configuration of InstabugLogger
    /// framework.
    /// Called at app didFinishLaunchingWithOptions function every time the app launches.
    ///
    /// `Parameters`
    /// support users by a fancy way to choose the storage option eg. Core data also the max
    /// number of logs as a storage  limit.
    /// It cleans the  disk store on every app launch.
    ///
    /// `Example of call`
    /// InstabugLogger.shared.configure(storageType: .coreData (limit: 1000) )
    
    public func configure (storageType:StorageType) {
        self.storageType = storageType
        storageService.configure() // Based on storage type e.g. CoreData.
    }
    
    // MARK: - Logging -
    
    /// `log` function responsible for  storing each log with it's level and timestamp.
    /// insertion occurred  on disk e.g. CoreData based on user configuration.
    ///
    /// `Parameters`  it accepts a log message and level.
    ///
    /// The limit of storage at disk-configured by the user
    /// if number of logs received more than  limit  configured, it  starts deleting the earliest logs.
    /// If log message is longer than 1000 character it truncates at 1000 and  appending ... at the
    
    public func log (_ level: LogLevel, message: String) {
        storageService.log(level, message: message)
    }
    
    
    // MARK: - Fetch logs  -
    
    /// ``Fetching Functions `` responsible for reading logs from disk and return it to user.
    /// User have three options to retrieve all logs either formatted or as an array of Log model.
    ///`Formatted error message `
    /// | ERROR: 2021-05-28 20:41:23.3620   SIGSEGV  Segmentation Fault occurred |
    
    public func fetchAllLogs() ->  [Log]  {
        let logs =  storageService.fetchAllLogs()
        return logs
    }
    
    public func fetchAllLogs(completionHandler:@escaping( ([Log])->Void)) {
        storageService.fetchAllLogs(completionHandler: completionHandler) 
    }
    
    public func fetchAllLogsFormatted () -> [String] { 
        let logs =  storageService.fetchAllLogsFormatted()
        return logs
    }
    
    // MARK: - Delete logs  -
    
    /// `deleteAllLogs`  function responsible for destroying logs from disk.
    public func deleteAllLogs() {
        storageService.deleteAllLogs()
    }
}
