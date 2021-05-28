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
    lazy  var storageService : StorageHandler = {
        let service = StorageEngine(storageType: storageType ?? .coreData(limit: 1000))
        return service
    }()
 
    //MARK: Configuration
    public func configure (storageType:StorageType) {
        self.storageType = storageType
        storageService.configure() // Based on storage type e.g. CoreData.
    }
    
    // MARK: Logging - 
    public func log (_ level: LogLevel, message: String) {
        storageService.log(level, message: message)
    }
    
    // MARK: Fetch logs  -
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
}
