//
//  ArminObjects.swift
//  Pods
//
//  Created by LYY on 2021/11/9.
//

import Foundation

// MARK: - protocol
public protocol ArminRequestProtocol: NSObjectProtocol {
    var id: Int {get}
    var requestType: YKNetRequestType {get}
    var event: YKNetRequestEvent {get set}
    var timeout: YKNetRequestTimeout {get set}
    var header: [String: String]? {get set}
    var parameters: [String: Any]? {get set}
}

public protocol ArminUploadProtocol: ArminRequestProtocol {
    var object: ArminUploadObject {get set}
}

// MARK: - models
public struct ArminUploadObject: CustomStringConvertible {
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
// MARK: - enums
