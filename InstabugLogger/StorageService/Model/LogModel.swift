//
//  LogModel.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation

//MARK: LogInput and formated Log model.Log models -

struct LogInput {
    let level: LogLevel
    let message: String
}
public struct Log  {
    let level: String
    let message: String
    let timeStamp: Date
}


//MARK: Log level type -
public enum LogLevel : String {
    case Alert         = "Alert"
    case Error         = "Error"
    case Debug         = "Debug"
    case Notice        = "Notice"
    case Warning       = "Warning"
    case Critical      = "Critical"
    case Emergency     = "Emergency"
    case Informational = "Informational"
}

//MARK: Adapt user LogInput to a formatted Log model. -
protocol LogTarget {
    var level: String {get}
    var message: String {get}
    var timeStamp: Date {get}
}

class LogAdapter {
    private let logItem : LogInput
    init(level:LogLevel, message:String) {
        let logInput = LogInput(level: level, message: message)
        self.logItem = logInput
    }
}

extension LogAdapter : LogTarget{
    var level: String {
        let errorLevel = logItem.level.rawValue
        return errorLevel
    }
    var message: String {
        let message = logItem.message
        let validMessage = validateMessage(msg:message)
        return validMessage
    }
    var timeStamp: Date {
        return Date()
    }
    
    
    private func validateMessage(msg:String)->String {
        let validMessage = msg.count > 1000 ? String(msg.prefix(1000)).appending("...") : msg
        return validMessage
    }
    
    func adapt () ->Log {
          let logItem = Log(level: self.level, message: self.message, timeStamp: self.timeStamp)
          return logItem
    }
}
