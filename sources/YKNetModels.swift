//
//  YKNetModels.swift
//  YKNetModels
//
//  Created by CallmeLetty on 2019/7/11.
//  Copyright © 2019 CallmeLetty. All rights reserved.
//

import Foundation

public typealias YKNetDicCompletion = (([String: Any]) -> Void)?
public typealias YKNetAnyCompletion = ((Any?) -> Void)?
public typealias YKNetStringCompletion = ((String) -> Void)?
public typealias YKNetIntCompletion = ((Int) -> Void)?
public typealias YKNetCompletion = (() -> Void)?

public typealias YKNetDownloadProgress = ((_ progress: Float) -> Void)?

public typealias YKNetDicEXCompletion = (([String: Any]) throws -> Void)?
public typealias YKNetStringExCompletion = ((String) throws -> Void)?
public typealias YKNetDataExCompletion = ((Data) throws -> Void)?

public typealias YKNetErrorCompletion = ((YKNetError) -> Void)?
public typealias YKNetErrorBoolCompletion = ((YKNetError) -> Bool)?
public typealias YKNetErrorRetryCompletion = ((YKNetError) -> YKNetRetryOptions)?

public typealias YKNetErrorRetryCompletionOC = ((YKNetErrorOC) -> TimeInterval)?

// MARK: enum
public enum YKNetRetryOptions {
    case retry(after: TimeInterval,
               newTask: YKNetRequestTaskProtocol? = nil), resign
}

public enum YKNetSwitch: Int, CustomStringConvertible {
    case off = 0, on = 1
    
    public var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    var boolValue: Bool {
        switch self {
        case .on:  return true
        case .off: return false
        }
    }
    
    var intValue: Int {
        switch self {
        case .on:  return 1
        case .off: return 0
        }
    }
    
    func cusDescription() -> String {
        switch self {
        case .on:  return "on"
        case .off: return "off"
        }
    }
}

public enum YKNetRequestType {
    case http(method: YKNetHTTPMethod,
              url: String)
    case socket(peer: String)
    
    var httpMethod: YKNetHTTPMethod? {
        switch self {
        case .http(let method, _):  return method
        default:                    return nil
        }
    }
    
    var url: String? {
        switch self {
        case .http(_, let url):  return url
        default:                 return nil
        }
    }
}

public enum YKNetResponse {
    case json(YKNetDicEXCompletion)
    case data(YKNetDataExCompletion)
    case string(YKNetStringExCompletion)
    case blank(YKNetCompletion)
}

public enum YKNetRequestTimeout {
    case low, medium, high, custom(TimeInterval)
    
    public var value: TimeInterval {
        switch self {
        case .low:               return 20
        case .medium:            return 10
        case .high:              return 3
        case .custom(let value): return value
        }
    }
}

public enum YKNetFileMIME {
    case png, zip
    
    public var text: String {
        switch self {
        case .png: return "image/png"
        case .zip: return "application/octet-stream"
        }
    }
}

// MARK: struct
public struct YKNetRequestEvent: YKNetRequestEventProtocol {
    public var name: String
    
    public var description: String {
        return cusDescription()
    }
    
    public init(name: String) {
        self.name = name
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        return name
    }
}

public struct YKNetUploadObject: CustomStringConvertible {
    public var fileKeyOnServer: String
    public var fileName: String
    public var fileData: Data
    public var mime: YKNetFileMIME
    
    public var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        return ["fileKeyOnServer": fileKeyOnServer,
                "fileName": fileName,
                "mime": mime.text].description
    }
}

public struct YKNetDownloadObject: CustomStringConvertible {
    public var targetDirectory: String
    public var cover: Bool
    
    public init(targetDirectory: String,
                cover: Bool = true) {
        self.targetDirectory = targetDirectory
        self.cover = cover
    }
    
    public var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    func cusDescription() -> String {
        return ["folderPath": targetDirectory].description
    }
}

public struct YKNetRequestTask: YKNetRequestTaskProtocol {
    public private(set) var id: Int
    public private(set) var requestType: YKNetRequestType
    
    public var event: YKNetRequestEvent
    public var timeout: YKNetRequestTimeout
    public var header: [String : String]?
    public var parameters: [String : Any]?
    
    public init(event: YKNetRequestEvent,
                type: YKNetRequestType,
                timeout: YKNetRequestTimeout = .medium,
                header: [String: String]? = nil,
                parameters: [String: Any]? = nil) {
        TaskId.value += 1
        self.id = TaskId.value
        self.event = event
        self.requestType = type
        self.timeout = timeout
        self.header = header
        self.parameters = parameters
    }
}

public struct YKNetUploadTask: YKNetUploadTaskProtocol, CustomStringConvertible {
    public var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    public private(set) var id: Int
    public private(set) var requestType: YKNetRequestType
    
    public var event: YKNetRequestEvent
    public var timeout: YKNetRequestTimeout
    public var header: [String: String]?
    public var parameters: [String: Any]?
    public var object: YKNetUploadObject
    
    public init(event: YKNetRequestEvent,
                timeout: YKNetRequestTimeout = .medium,
                object: YKNetUploadObject,
                url: String,
                header: [String: String]? = nil,
                parameters: [String: Any]? = nil) {
        TaskId.value += 1
        self.id = TaskId.value
        self.object = object
        self.requestType = .http(method: .post,
                                 url: url)
        self.event = event
        self.timeout = timeout
        self.header = header
        self.parameters = parameters
    }
    
    func cusDescription() -> String {
        let dic: [String: Any] = ["object": object.description,
                                  "header": OptionsDescription.any(header),
                                  "parameters": OptionsDescription.any(parameters)]
        return dic.description
    }
}

public struct YKNetDownloadTask: YKNetDownloadTaskProtocol, CustomStringConvertible {
    public var description: String {
        return cusDescription()
    }
    
    var debugDescription: String {
        return cusDescription()
    }
    
    public private(set) var id: Int
    public private(set) var requestType: YKNetRequestType
    
    public var event: YKNetRequestEvent
    public var timeout: YKNetRequestTimeout
    public var header: [String: String]?
    public var parameters: [String: Any]?
    public var object: YKNetDownloadObject
    
    public init(event: YKNetRequestEvent,
                timeout: YKNetRequestTimeout = .medium,
                object: YKNetDownloadObject,
                url: String,
                header: [String: String]? = nil,
                parameters: [String: Any]? = nil) {
        TaskId.value += 1
        self.id = TaskId.value
        self.object = object
        self.requestType = .http(method: .download,
                                 url: url)
        self.event = event
        self.timeout = timeout
        self.header = header
        self.parameters = parameters
    }
    
    func cusDescription() -> String {
        let dic: [String: Any] = ["object": object.description,
                                  "header": OptionsDescription.any(header),
                                  "parameters": OptionsDescription.any(parameters)]
        return dic.description
    }
}

fileprivate struct TaskId {
    static var value: Int = Date.millisecondTimestamp
}

// MARK: OC Models
@objc public class YKNetRequestEventOC: NSObject {
    @objc public var name: String
    
    @objc public init(name: String) {
        self.name = name
    }
}

@objc public enum YKNetRequestTypeOC: Int {
    case http, socket
}

@objc public enum YKNetHTTPMethodOC: Int {
//    case options
    case get
    case head
    case post
    case put
//    case patch
    case delete
//    case trace
//    case connect
    case download
}

@objc public enum YKNetResponseTypeOC: Int {
    case json, data, blank
}

@objc public enum YKNetFileMIMEOC: Int {
    case png, zip
}

@objc public class YKNetRequestTypeObjectOC: NSObject {
    @objc public var type: YKNetRequestTypeOC
    
    @objc public init(type: YKNetRequestTypeOC) {
        self.type = type
    }
}

@objc public class YKNetRequestTypeJsonObjectOC: YKNetRequestTypeObjectOC {
    @objc public var method: YKNetHTTPMethodOC
    @objc public var url: String
    
    @objc public init(method: YKNetHTTPMethodOC,
                      url: String) {
        self.method = method
        self.url = url
        super.init(type: .http)
    }
}

@objc public class YKNetRequestTypeSocketObjectOC: YKNetRequestTypeObjectOC {
    @objc public var peer: String

    @objc public init(peer: String) {
        self.peer = peer
        super.init(type: .socket)
    }
}

@objc public class YKNetRequestTaskOC: NSObject {
    @objc public private(set) var id: Int
    @objc public var event: YKNetRequestEventOC
    @objc public var requestType: YKNetRequestTypeObjectOC
    @objc public var timeout: TimeInterval
    @objc public var header: [String : String]?
    @objc public var parameters: [String : Any]?
    
    @objc public init(event: YKNetRequestEventOC,
                type: YKNetRequestTypeObjectOC,
                timeout: TimeInterval = 10,
                header: [String: String]? = nil,
                parameters: [String: Any]? = nil) {
        TaskId.value += 1
        self.id = TaskId.value
        self.event = event
        self.requestType = type
        self.timeout = timeout
        self.header = header
        self.parameters = parameters
    }
}

@objc public class YKNetResponseOC: NSObject {
    @objc public var type: YKNetResponseTypeOC
    @objc public var json: [String: Any]?
    @objc public var data: Data?
    
    @objc public init(type: YKNetResponseTypeOC,
                      json: [String: Any]?,
                      data: Data?) {
        self.type = type
        self.json = json
        self.data = data
    }
}

@objc public class YKNetUploadObjectOC: NSObject {
    @objc public var fileKeyOnServer: String
    @objc public var fileName: String
    @objc public var fileData: Data
    @objc public var mime: YKNetFileMIMEOC
    
    @objc public init(fileKeyOnServer: String,
                      fileName: String,
                      fileData: Data,
                      mime: YKNetFileMIMEOC) {
        self.fileKeyOnServer = fileKeyOnServer
        self.fileName = fileName
        self.fileData = fileData
        self.mime = mime
    }
}

@objc public class YKNetUploadTaskOC: NSObject {
    @objc public private(set) var id: Int
    @objc public var event: YKNetRequestEventOC
    @objc public var timeout: TimeInterval
    @objc public var url: String
    @objc public var header: [String : String]?
    @objc public var parameters: [String : Any]?
    @objc public var object: YKNetUploadObjectOC
    
    public private(set) var requestType: YKNetRequestType
    
    @objc public init(event: YKNetRequestEventOC,
                      timeout: TimeInterval,
                      object: YKNetUploadObjectOC,
                      url: String,
                      header: [String: String]? = nil,
                      parameters: [String: Any]? = nil) {
        TaskId.value += 1
        self.id = TaskId.value
        self.url = url
        self.object = object
        self.requestType = .http(method: .post,
                                 url: url)
        self.event = event
        
        self.timeout = timeout
        self.header = header
        self.parameters = parameters
    }
}

@objc public class YKNetDownloadObjectOC: NSObject {
    @objc public var targetDirectory: String
    @objc public var cover: Bool

    @objc public init(targetDirectory: String,
                      cover: Bool) {
        self.targetDirectory = targetDirectory
        self.cover = cover
    }
}

@objc public class YKNetDownloadTaskOC: NSObject {
    @objc public private(set) var id: Int
    @objc public var event: YKNetRequestEventOC
    @objc public var timeout: TimeInterval
    @objc public var url: String
    @objc public var header: [String : String]?
    @objc public var parameters: [String : Any]?
    @objc public var object: YKNetDownloadObjectOC
    
    public private(set) var requestType: YKNetRequestType
    
    @objc public init(event: YKNetRequestEventOC,
                      timeout: TimeInterval,
                      object: YKNetDownloadObjectOC,
                      url: String,
                      header: [String: String]? = nil,
                      parameters: [String: Any]? = nil) {
        TaskId.value += 1
        self.id = TaskId.value
        self.url = url
        self.object = object
        self.requestType = .http(method: .post,
                                 url: url)
        self.event = event
        
        self.timeout = timeout
        self.header = header
        self.parameters = parameters
    }
}

public enum YKNetHTTPMethod {
    case get
    case head
    case post
    case put
    case delete
    case download
    
    var stringValue: String {
        switch self {
        case .get: return "GET"
        case .head: return "HEAD"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        case .download: return "DOWNLOAD"
        }
    }
}
