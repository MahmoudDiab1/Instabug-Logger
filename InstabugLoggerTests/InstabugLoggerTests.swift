//
//  InstabugLoggerTests.swift
//  InstabugLoggerTests
//
//  Created by Yosef Hamza on 19/04/2021.
//

import XCTest
@testable import InstabugLogger

//(todo): Setup core data stack to run testing operations at the  memory not at the actual storage.

class InstabugLoggerTests: XCTestCase {
    
    var level: LogLevel!
    var message: String!
    var logger: InstabugLogger!
    var defaultLogsToFree: Int!
    
    
    override func setUpWithError() throws {
        defaultLogsToFree = 1
        level = .Error
        message = "Error occurred while unwrapping optional."
            logger = InstabugLogger()
        let loggerConfiguration = StorageConfiguration(storageType: .coreData, limit: 1000)
        logger.configure(configurations: loggerConfiguration)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is
        logger = nil
    }

    
    func test_Log() {
        logger.log(level, message: message)
        XCTAssertEqual(logger.fetchAllLogs().count, 1)
    }

    func test_Log_OverLimit() {
        for _ in 0..<1000{
        logger.log(.Warning, message: message)
        }
        logger.log(.Debug, message: message)
        let logs = logger.fetchAllLogs()
        XCTAssertEqual(logs.last?.level, "Debug")
    }

    func test_FetchAllLogs() {
        var logs = logger.fetchAllLogs()
        XCTAssertTrue(logs.isEmpty)
        logger.log(level, message: message)
        logs = logger.fetchAllLogs()
        XCTAssertEqual(logs.count, 1)
    }

    func test_FetchAllLogsWithClosures() {
        logger.fetchAllLogs { logs in
            XCTAssertTrue(logs.isEmpty)
        }
        logger.log(level, message: message)
        logger.fetchAllLogs { logs in
            XCTAssertEqual(logs.count, 1)
        }
    }

    func test_FetchAllLogsFormatted () {
        var logsFormatted = logger.fetchAllLogsFormatted()
        XCTAssertTrue(logsFormatted.isEmpty)
        logger.log(level, message: message)
        logsFormatted = logger.fetchAllLogsFormatted() 
        XCTAssertEqual(logsFormatted[0].first,"|" )
    }
    
    func test_DeleteAllLog( ) {
        logger.deleteLogs(logs: .allLogs)
        let storedLogs = logger.fetchAllLogs()
        XCTAssertEqual(storedLogs.count, 0)
    }
     
    func test_DeleteSomeLogs() {
        for _ in 1 ... 5 {
            logger.log(level, message: message) 
        }
        logger.deleteLogs(logs: .someOfLogs(number: 5))
        let storedLogs = logger.fetchAllLogs()
        XCTAssertEqual(storedLogs.count, 0)
    }
    
    func test_DeleteSomeLogsMoreThanCurrentLogs () {
        let logs: DeletionType = .someOfLogs(number:6)
        for _ in 1 ... 5 {
            logger.log(level, message: message)
        }
        logger.deleteLogs(logs: logs)
        let storedLogs = logger.fetchAllLogs()
        XCTAssertEqual(storedLogs.count, 0)
    }
    
    func test_DeleteZeroLogs () {
        for _ in 1 ... 5 {logger.log(level, message: message)}
        let logs: DeletionType = .someOfLogs(number:0)
        logger.deleteLogs(logs: logs)
        let storedLogs = logger.fetchAllLogs()
        XCTAssertEqual(storedLogs.count, 5)
    }
    
    func test_DeleteAllLogs () {
        for _ in 1 ... 5 {
            logger.log(level, message: message)
        }
        var storedLogs = logger.fetchAllLogs()
        XCTAssertEqual(storedLogs.count, 5)
        logger.deleteLogs(logs: .allLogs)
        storedLogs = logger.fetchAllLogs()
        XCTAssertEqual(storedLogs.count, 0)
    }
    
}
