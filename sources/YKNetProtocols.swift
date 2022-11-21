//
//  YKNetProtocols.swift
//  YKNetProtocols
//
//  Created by CallmeLetty on 2019/6/19.
//  Copyright © 2019 CallmeLetty. All rights reserved.
//

import Foundation

public protocol YKNetLogTube: NSObjectProtocol {
    func log(info: String, extra: String?)
    func log(warning: String, extra: String?)
    func log(error: YKNetError, extra: String?)
}

@objc public protocol YKNetLogTubeOC: NSObjectProtocol {
    func log(info: String, extra: String?)
    func log(warning: String, extra: String?)
    func log(error: YKNetErrorOC, extra: String?)
}

public protocol YKNetRequestEventProtocol: CustomStringConvertible {
    var name: String {get set}
}

public protocol YKNetRequestTaskProtocol {
    var id: Int {get}
    var requestType: YKNetRequestType {get}
    var event: YKNetRequestEvent {get set}
    var timeout: YKNetRequestTimeout {get set}
    var header: [String: String]? {get set}
    var parameters: [String: Any]? {get set}
}

public protocol YKNetUploadTaskProtocol: YKNetRequestTaskProtocol {
    var object: YKNetUploadObject {get set}
}

public protocol YKNetDownloadTaskProtocol: YKNetRequestTaskProtocol {
    var object: YKNetDownloadObject {get set}
}

// MARK: - Request APIs
public protocol YKNetRequestAPIsProtocol {
    func request(task: YKNetRequestTaskProtocol,
                 responseOnQueue: DispatchQueue?,
                 success: YKNetResponse?,
                 failRetry: YKNetErrorRetryCompletion)
    
    func upload(task: YKNetUploadTaskProtocol,
                responseOnQueue: DispatchQueue?,
                success: YKNetResponse?,
                failRetry: YKNetErrorRetryCompletion)
    
    func download(task: YKNetDownloadTaskProtocol,
                  responseOnQueue: DispatchQueue?,
                  progress: YKNetDownloadProgress,
                  success: YKNetResponse?,
                  failRetry: YKNetErrorRetryCompletion)
    
    func stopTasks(urls: [String]?)
}
