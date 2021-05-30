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
    var level:LogLevel!
    var message:String!
    var logger:InstabugLogger!

    override func setUpWithError() throws {
        level = .Error
        message = "Error occurred while unwrapping optional."
            logger = InstabugLogger()
        let loggerConfiguration = StorageConfiguration(storageType: .coreData, limit: 1000)
        logger.configure(configurations: loggerConfiguration)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is
        //logger.deleteAllLogs()
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
        XCTAssertEqual(logs.first?.level, "Debug")
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
}
