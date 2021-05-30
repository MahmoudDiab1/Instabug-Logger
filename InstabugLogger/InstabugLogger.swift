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
    
    public static let shared: InstabugLogger = {
        let instance = InstabugLogger()
        return instance
    }()
    
    private var storageService : StorageEngine!
    private let defaultStorageOption:StorageType = .coreData
    private let defaultStorageLimit = 1000
    
    private var defaultConfig : StorageConfiguration {
        let configuration  = StorageConfiguration(storageType: .coreData,
                                                  limit:defaultStorageLimit )
        return configuration
    }
    
    //MARK: - Configuration -
    
    ///`Configure` function responsible for the basic configuration of InstabugLogger
    /// framework.
    /// Called at app didFinishLaunchingWithOptions function every time the app launches.
    ///
    /// `Parameters`
    /// support users by a fancy way to configure InstabugLogger by the storage option like Core data and the max number of Logs to be stored
    /// number of logs as a storage  limit through the input: configurations: StorageConfiguration.
    ///
    /// - `Configure` function  parameter is an`Optional` parameter.
    /// - Default  value for configurations is (storageType: .coreData, limit: 1000)
    /// - Note: Different storage options to be implemented beside core data like files.
    /// - It cleans the  disk store on every app launch.
    ///
    /// `Custom configuration`
    /// let configurations = StorageConfiguration(storageType: .coreData, limit:1500)
    /// InstabugLogger.shared.configure (configurations: configurations)
    ///
    //// `Default configuration`
    /// InstabugLogger.shared.configure ( )
    
    public func configure (configurations: StorageConfiguration? = nil) { 
        self.storageService = StorageEngine(configuration: configurations ?? defaultConfig)
        if let storageService = self.storageService {
            storageService.configure() // Based on storage type e.g. CoreData.
        }
        
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
    ///
    /// Use fetchAllLogsFormatted function to return formatted logs.
    /// Example of `Formatted error message `
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
