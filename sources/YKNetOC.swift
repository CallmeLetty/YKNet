//
//  YKNet_OC.swift
//  YKNet
//
//  Created by CavanSu on 2020/8/18.
//  Copyright © 2020 CavanSu. All rights reserved.
//

@objc public protocol YKNetDelegateOC: NSObjectProtocol {
    func ykNet(_ client: YKNetOC,
               requestSuccess event: YKNetRequestEventOC,
               startTime: TimeInterval,
               url: String)
    func ykNet(_ client: YKNetOC,
               requestFail error: YKNetErrorOC,
               event: YKNetRequestEventOC,
               url: String)
}

@objc public class YKNetErrorOC: NSError {
    @objc public var reposeData: Data?
}

@objc open class YKNetOC: YKNet {
    @objc public weak var delegateOC: YKNetDelegateOC?
    @objc public weak var logTubeOC: YKNetLogTubeOC?
    
    @objc public init(delegate: YKNetDelegateOC? = nil,
                      logTube: YKNetLogTubeOC? = nil) {
        self.delegateOC = delegate
        super.init(delegate: nil,
                   logTube: nil)
        self.logTube = self
        self.delegate = self
        self.logTubeOC = logTube
    }
    
    @objc public func request(task: YKNetRequestTaskOC,
                              responseOnQueue: DispatchQueue?,
                              successCallbackContent: YKNetResponseTypeOC,
                              success: ((YKNetResponseOC) -> Void)? = nil,
                              fail: YKNetErrorRetryCompletionOC = nil) {
        let swift_task = YKNetRequestTask.oc(task)
        
        let response = successFromOC(successCallbackContent: successCallbackContent,
                                      success: success)
        
        request(task: swift_task,
                responseOnQueue: responseOnQueue,
                success: response,
                failRetry: failFromOC(fail: fail))
    }
    
    @objc public func upload(task: YKNetUploadTaskOC,
                             responseOnQueue: DispatchQueue?,
                             successCallbackContent: YKNetResponseTypeOC,
                             success: ((YKNetResponseOC) -> Void)? = nil,
                             fail: YKNetErrorRetryCompletionOC = nil) {
        let swift_task = YKNetUploadTask.oc(task)
        
        let response = successFromOC(successCallbackContent: successCallbackContent,
                                      success: success)
        
        upload(task: swift_task,
               responseOnQueue: responseOnQueue,
               success: response,
               failRetry: failFromOC(fail: fail))
    }
    
    @objc public func download(task: YKNetDownloadTaskOC,
                               responseOnQueue: DispatchQueue?,
                               successCallbackContent: YKNetResponseTypeOC,
                               progress: ((_ progress: Float) -> Void)? = nil,
                               success: ((YKNetResponseOC) -> Void)? = nil,
                               fail: YKNetErrorRetryCompletionOC = nil) {
        let response = successFromOC(successCallbackContent: successCallbackContent,
                                     success: success)
        
        let swift_task = YKNetDownloadTask.oc(task)
        download(task: swift_task,
                 responseOnQueue: responseOnQueue,
                 progress: progress,
                 success: response,
                 failRetry: failFromOC(fail: fail))
    }
}

private extension YKNetOC {
    func successFromOC(successCallbackContent: YKNetResponseTypeOC,
                        success: ((YKNetResponseOC) -> Void)? = nil) -> YKNetResponse {
        var response: YKNetResponse
        
        switch successCallbackContent {
        case .json:
            response = YKNetResponse.json({ (json) in
                let response_oc = YKNetResponseOC(type: successCallbackContent,
                                               json: json,
                                               data: nil)
                
                if let success = success {
                    success(response_oc)
                }
            })
        case .data:
            response = YKNetResponse.data({ (data) in
                let response_oc = YKNetResponseOC(type: successCallbackContent,
                                               json: nil,
                                               data: data)
                
                if let success = success {
                    success(response_oc)
                }
            })
        case .blank:
            response = YKNetResponse.blank({
                let response_oc = YKNetResponseOC(type: successCallbackContent,
                                               json: nil,
                                               data: nil)
                
                if let success = success {
                    success(response_oc)
                }
            })
        }
        
        return response
    }
    
    func failFromOC(fail: YKNetErrorRetryCompletionOC) -> YKNetErrorRetryCompletion {
        func retryCompletion(error: YKNetError) -> YKNetRetryOptions {
            if let failBlock = fail {
                let swift_error = error
                let oc_error = YKNetErrorOC(domain: swift_error.localizedDescription,
                                         code: swift_error.code ?? -1,
                                         userInfo: nil)
                oc_error.reposeData = swift_error.responseData
                let failRetryInterval = failBlock(oc_error);
                
                if failRetryInterval > 0 {
                    return .retry(after: failRetryInterval)
                } else {
                    return .resign
                }
            } else {
                return .resign
            }
        }
        
        return retryCompletion(error:)
    }
}

extension YKNetOC: YKNetDelegate {
    public func ykNet(_ client: YKNet,
                      requestSuccess event: YKNetRequestEvent,
                      startTime: TimeInterval,
                      url: String) {
        let eventOC = YKNetRequestEventOC(name: event.name)
        self.delegateOC?.ykNet(self,
                               requestSuccess: eventOC,
                               startTime: startTime,
                               url: url)
    }
    
    public func ykNet(_ client: YKNet,
                      requestFail error: YKNetError,
                      event: YKNetRequestEvent,
                      url: String) {
        let eventOC = YKNetRequestEventOC(name: event.name)
        let errorOC = YKNetErrorOC(domain: error.localizedDescription,
                                code: error.code ?? -1,
                                userInfo: nil)
        self.delegateOC?.ykNet(self,
                               requestFail: errorOC,
                               event: eventOC,
                               url: url)
    }
}

extension YKNetOC: YKNetLogTube {
    public func log(info: String,
                    extra: String?) {
        logTubeOC?.log(info: info,
                       extra: extra)
    }
    
    public func log(warning: String,
                    extra: String?) {
        logTubeOC?.log(warning: warning,
                       extra: extra)
    }
    
    public func log(error: YKNetError,
                    extra: String?) {
        let oc_error = YKNetErrorOC(domain: error.localizedDescription,
                                 code: error.code ?? -1,
                                 userInfo: nil)
        oc_error.reposeData = error.responseData
        logTubeOC?.log(error: oc_error,
                       extra: extra)
    }
}

fileprivate extension YKNetRequestTask {
    static func oc(_ item: YKNetRequestTaskOC) -> YKNetRequestTask {
        let swift_event = YKNetRequestEvent(name: item.event.name)
        let swift_type = YKNetRequestType.oc(item.requestType)
        
        return YKNetRequestTask(event: swift_event,
                             type: swift_type,
                             timeout: .custom(item.timeout),
                             header: item.header,
                             parameters: item.parameters)
    }
}

fileprivate extension YKNetRequestType {
    static func oc(_ item: YKNetRequestTypeObjectOC) -> YKNetRequestType {
        switch item.type {
        case .http:
            if let http = item as? YKNetRequestTypeJsonObjectOC {
                return YKNetRequestType.http(YKNetHTTPMethod.oc(http.method),
                                          url: http.url)
            } else {
                fatalError("YKNetRequestType error")
            }
        case .socket:
            if let socket = item as? YKNetRequestTypeSocketObjectOC {
                return YKNetRequestType.socket(peer: socket.peer)
            } else {
                fatalError("YKNetRequestType error")
            }
        }
    }
}

fileprivate extension YKNetHTTPMethod {
    static func oc(_ item: YKNetHTTPMethodOC) -> YKNetHTTPMethod {
        switch item {
//        case .options: return .options
//        case .connect: return .connect
        case .delete:  return .delete
        case .get:     return .get
        case .head:    return .head
//        case .patch:   return .patch
        case .post:    return .post
        case .put:     return .put
        case .download: return .download
//        case .trace:   return .trace
        }
    }
}

fileprivate extension YKNetFileMIME {
    static func oc(_ item: YKNetFileMIMEOC) -> YKNetFileMIME {
        switch item {
        case .png: return .png
        case .zip: return .zip
        }
    }
}

fileprivate extension YKNetUploadTask {
    static func oc(_ item: YKNetUploadTaskOC) -> YKNetUploadTask {
        let siwft_mime = YKNetFileMIME.oc(item.object.mime)
        let swift_object = YKNetUploadObject(fileKeyOnServer: item.object.fileKeyOnServer,
                                          fileName: item.object.fileName,
                                          fileData: item.object.fileData,
                                          mime: siwft_mime)
        
        let swift_event = YKNetRequestEvent(name: item.event.name)
        
        let swift_task = YKNetUploadTask(event: swift_event,
                                      timeout: .custom(item.timeout),
                                      object: swift_object,
                                      url: item.url,
                                      header: item.header,
                                      parameters: item.header)
        return swift_task
    }
}

fileprivate extension YKNetDownloadTask {
    static func oc(_ item: YKNetDownloadTaskOC) -> YKNetDownloadTask {
        let swift_object = YKNetDownloadObject(targetDirectory: item.object.targetDirectory,
                                            cover: item.object.cover)
        let swift_event = YKNetRequestEvent(name: item.event.name)

        let swift_task = YKNetDownloadTask(event: swift_event,
                                        timeout: .custom(item.timeout),
                                        object: swift_object,
                                        url: item.url,
                                        header: item.header,
                                        parameters: item.header)
        return swift_task
    }
}
