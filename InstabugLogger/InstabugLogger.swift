//
//  InstabugLogger.swift
//  InstabugLogger
//
//  Created by Yosef Hamza on 19/04/2021.
//

import Foundation
import CoreData  

public class InstabugLogger  {
    //MARK: Properties -
    public static var shared : InstabugLogger = InstabugLogger()
    
    private var storageType:StorageType? 
    lazy var storageService : StorageHandler = {
        let service = StorageEngine(storageType: storageType ?? .coreData)
        return service
    }()
 
    //MARK: Configuration
    public func configure (storageType:StorageType) {
        self.storageType = storageType
        storageService.configure() // Based on storage type e.g. CoreData.
    }
    
    // MARK: Logging -
    /// The logging framework should accept a log message and level.
    public func log (_ level: LogLevel, message: String) {
        storageService.log(level, message: message)
    }
    
    // MARK: Fetch logs -
    public func fetchAllLogs() -> [Log] {
        let logs =  storageService.fetchAllLogs()
        return logs
    }
    
    public func fetchAllLogs(completionHandler:@escaping( ([Log])->Void)) {
        storageService.fetchAllLogs(completionHandler: completionHandler)
    }
}
