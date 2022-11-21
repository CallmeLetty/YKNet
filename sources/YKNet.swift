//
//  YKNet.swift
//  YKNet
//
//  Created by CallmeLetty on 2019/6/23.
//  Copyright © 2019 CallmeLetty. All rights reserved.
//

/**
YKNet owns only one URLSessionManager and one YKNetSessionDelegator which is weak and implements URLSession, because the session will strong own its URLSessionManager.
 */

import Foundation

public protocol YKNetDelegate: NSObjectProtocol {
    func ykNet(_ client: YKNet,
               requestSuccess event: YKNetRequestEvent,
               startTime: TimeInterval,
               url: String)
    func ykNet(_ client: YKNet,
               requestFail error: YKNetError,
               event: YKNetRequestEvent,
               url: String)
}

open class YKNet: NSObject, YKNetRequestAPIsProtocol {
    public weak var delegate: YKNetDelegate?
    public weak var logTube: YKNetLogTube?
    
    private let session: URLSession
    private let fileHandler = ArFileHandler()
    private let requestMaker = YKNetRequestMaker()
    
    // String: YKNetRequestEvent name
    private lazy var afterWorkers = [String: YKNetAfterWorker]()
    
    // Key为URLSessionTask的taskIdentifier，以便于在URLSessionDelegate中取值，目前只处理download tasks
    private(set) lazy var taskHandlers = [Int: YKNetTaskHandler]()
    
    private var responseQueue = DispatchQueue(label: "com.ykNet.response.thread")
    private var afterQueue = DispatchQueue(label: "com.ykNet.after.thread")
    
    public init(delegate: YKNetDelegate? = nil,
                logTube: YKNetLogTube? = nil) {
        self.delegate = delegate
        self.logTube = logTube
        
        let sessionDelegate = YKNetSessionDelegator()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = YKNet.defaultHTTPHeaders
        self.session = URLSession(configuration: URLSessionConfiguration.default,
                                  delegate: sessionDelegate,
                                  delegateQueue: .current)
        
        super.init()
        sessionDelegate.setArmin(self)
        sessionDelegate.setFileHandler(self.fileHandler)
    }
    
    func handleHttpSuccess(data: Data?,
                           location: String? = nil,
                           startTime: TimeInterval,
                           from task: YKNetRequestTaskProtocol,
                           success: YKNetResponse?) {
        
        requestSuccess(of: task.event,
                       startTime: startTime,
                       with: task.requestType.url!)
        
        guard let successRes = success else {
            return
        }
        
        switch successRes {
        case .json(let arDicEXCompletion):
            guard let _data = data,
                  let json = try? _data.json() else {
                break
            }
            
            self.log(info: "request success",
                     extra: "event: \(task.event), json: \(json.description)")
            guard let completion = arDicEXCompletion else {
                break
            }
            
            try? completion(json)
        case .data(let arDataExCompletion):
            guard let _data = data else {
                break
            }
            self.log(info: "request success",
                     extra: "event: \(task.event), data.count: \(_data.count)")
            guard let completion = arDataExCompletion else {
                break
            }
            
            try? completion(_data)
        case .string(let arStringCompletion):
            guard let filePath = location else {
                break
            }
            self.log(info: "request success",
                     extra: "event: \(task.event),path: \(filePath)")
            guard let completion = arStringCompletion else {
                break
            }
            try? completion(filePath)
        case .blank(let arCompletion):
            self.log(info: "request success",
                     extra: "event: \(task.event)")
            guard let completion = arCompletion else {
                break
            }
            completion()
        }
    }
}

// MARK: - YKNetRequestAPIsProtocol
public extension YKNet {
    func request(task: YKNetRequestTaskProtocol,
                 responseOnQueue: DispatchQueue? = nil,
                 success: YKNetResponse? = nil,
                 failRetry: YKNetErrorRetryCompletion = nil) {
        let queue = responseOnQueue == nil ? self.responseQueue : responseOnQueue
        executeRequst(task: task,
                      responseOnQueue: queue!,
                      success: success) { [weak self] (error) in
            guard let `self` = self else {
                return
            }
            guard let eRetry = failRetry else {
                self.removeWorker(of: task.event)
                return
            }
            
            let option = eRetry(error)
            switch option {
            case .retry(let time, let newTask):
                var reTask: YKNetRequestTaskProtocol
                
                if let newTask = newTask {
                    reTask = newTask
                } else {
                    reTask = task
                }
                
                let work = self.worker(of: reTask.event)
                work.perform(after: time,
                             on: self.afterQueue, {
                                self.request(task: reTask,
                                             success: success,
                                             failRetry: failRetry)
                             })
            case .resign:
                break
            }
        }
    }
    
    func upload(task: YKNetUploadTaskProtocol,
                responseOnQueue: DispatchQueue? = nil,
                success: YKNetResponse? = nil,
                failRetry: YKNetErrorRetryCompletion = nil) {
        let queue = responseOnQueue == nil ? self.responseQueue : responseOnQueue
        executeUpload(task: task,
                      responseOnQueue: queue!,
                      success: success) { [weak self] (error) in
            guard let `self` = self else {
                return
            }
            guard let eRetry = failRetry else {
                self.removeWorker(of: task.event)
                return
            }
            
            let option = eRetry(error)
            switch option {
            case .retry(let time, let newTask):
                var reTask: YKNetUploadTaskProtocol
                
                if let newTask = newTask as? YKNetUploadTaskProtocol {
                    reTask = newTask
                } else {
                    reTask = task
                }
                
                let work = self.worker(of: reTask.event)
                work.perform(after: time, on: self.afterQueue, {
                    self.upload(task: reTask, success: success, failRetry: failRetry)
                })
            case .resign:
                break
            }
        }
    }
    
    func download(task: YKNetDownloadTaskProtocol,
                  responseOnQueue: DispatchQueue? = nil,
                  progress: YKNetDownloadProgress = nil,
                  success: YKNetResponse?,
                  failRetry: YKNetErrorRetryCompletion) {
        let queue = responseOnQueue == nil ? self.responseQueue : responseOnQueue
        executeDownload(task: task,
                        responseOnQueue: queue!,
                        progress: progress,
                        success: success) { [weak self] (error) in
            guard let `self` = self else {
                return
            }
            
            guard let eRetry = failRetry else {
                self.removeWorker(of: task.event)
                return
            }
            let option = eRetry(error)
            switch option {
            case .retry(let time, let newTask):
                var reTask: YKNetDownloadTaskProtocol
                if let newReTask = newTask as? YKNetDownloadTaskProtocol {
                    reTask = newReTask
                } else {
                    reTask = task
                }
                
                let work = self.worker(of: reTask.event)
                work.perform(after: time, on: self.afterQueue, {
                    self.download(task: reTask,
                                  responseOnQueue: responseOnQueue,
                                  progress: progress,
                                  success: success,
                                  failRetry: failRetry)
                })
            case .resign:
                break
            }
        }
    }
    
    func stopTasks(urls: [String]?) {
        guard let allUrls = urls else {
            taskHandlers.keys.forEach {[weak self] id in
                self?.removeTask(taskId: id)
            }
            return
        }
        
        for url in allUrls {
            for (id,handler) in taskHandlers {
                if handler.urlStr == url {
                    removeTask(taskId: id)
                }
            }
        }
    }
    
    func removeTask(taskId: Int) {
        taskHandlers[taskId]?.sessionTask.cancel()
        taskHandlers.removeValue(forKey: taskId)
    }
}

// MARK: private
private extension YKNet {
    func executeRequst(task: YKNetRequestTaskProtocol,
                       responseOnQueue: DispatchQueue,
                       success: YKNetResponse?,
                       requestFail: YKNetErrorCompletion) {
        guard let method = task.requestType.httpMethod else {
            requestFail?(YKNetError(type: .valueNil("method")))
            return
        }
        
        guard let urlStr = task.requestType.url else {
            requestFail?(YKNetError(type: .valueNil("url")))
            return
        }
        
        var request: URLRequest?
        do {
            request = try requestMaker.makeRequest(urlstr: urlStr,
                                                   timeout: task.timeout.value,
                                                   method: method,
                                                   headers: task.header,
                                                   params: task.parameters)
        }catch{
            requestFail?(error as! YKNetError)
            return
        }
        
        guard let `request` = request else {
            requestFail?(YKNetError(type: .valueNil("request")))
            return
        }
        
        let startTime = Date.timeIntervalSinceReferenceDate
        let dataTask = session.dataTask(with: request) {[weak self] (data, response, error) in
            guard let `self` = self else {
                return
            }
            
            // handle error
            if let err = error {
                let YKNetError = YKNetError.fail(err.localizedDescription,
                                                 code: -1,
                                                 extra: nil,
                                                 responseData: data)
                self.request(error: YKNetError,
                             of: task.event,
                             with: urlStr)
                requestFail?(YKNetError)
                return
            }
            
            // handle success
            self.handleHttpSuccess(data: data,
                                   startTime: startTime,
                                   from: task,
                                   success: success)
        }
        
        dataTask.resume()
    }
    
    func executeUpload(task: YKNetUploadTaskProtocol,
                       responseOnQueue: DispatchQueue,
                       success: YKNetResponse?,
                       requestFail: YKNetErrorCompletion) {
        guard let urlStr = task.requestType.url else {
            requestFail?(YKNetError(type: .valueNil("url")))
            return
        }
        
        let startTime = Date.timeIntervalSinceReferenceDate
        
        var request: URLRequest?
        do {
            let request = try requestMaker.makeDataRequest(urlstr: urlStr,
                                                           timeout: task.timeout.value,
                                                           params: task.parameters,
                                                           uploadObject: task.object)
        }catch{
            requestFail?(error as! YKNetError)
            return
        }
        
        guard let `request` = request else {
            requestFail?(YKNetError(type: .valueNil("request")))
            return
        }
        
        let uploadTask = session.dataTask(with: request) {[weak self] (data, response, error) in
            guard let `self` = self else {
                return
            }
            
            // handle error
            if let err = error {
                let YKNetError = YKNetError.fail(err.localizedDescription,
                                                 code: -1,
                                                 extra: nil,
                                                 responseData: data)
                self.request(error: YKNetError,
                             of: task.event,
                             with: urlStr)
                requestFail?(YKNetError)
                return
            }
            
            // handle success
            responseOnQueue.async {
                self.handleHttpSuccess(data: data,
                                       startTime: startTime,
                                       from: task,
                                       success: success)
            }
            
        }
        
        uploadTask.resume()
    }
    
    func executeDownload(task: YKNetDownloadTaskProtocol,
                         responseOnQueue: DispatchQueue,
                         progress: YKNetDownloadProgress = nil,
                         success: YKNetResponse?,
                         requestFail: YKNetErrorCompletion) {
        let method = YKNetHTTPMethod.download
        guard let urlStr = task.requestType.url,
              let url = requestMaker.makeUrl(urlstr: urlStr,
                                             httpMethod: method,
                                             parameters: task.parameters) else {
            let YKNetError = YKNetError(type: .valueNil("url"))
            requestFail?(YKNetError)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.stringValue
        
        let startTime = Date.timeIntervalSinceReferenceDate
        
        let downloadTask = session.downloadTask(with: url)
        do {
            try addTaskHandler(task: task,
                               sessionTask: downloadTask,
                               urlStr: urlStr,
                               responseQueue: responseOnQueue,
                               startTime: startTime,
                               progress: progress,
                               success: success,
                               requestFail: requestFail)
        } catch {
            self.request(error: error as! YKNetError,
                         of: task.event,
                         with: urlStr)
            requestFail?(error as! YKNetError)
            return
        }
        
        downloadTask.resume()
    }
    
    func addTaskHandler(task: YKNetRequestTaskProtocol,
                        sessionTask: URLSessionTask,
                        urlStr: String,
                        responseQueue: DispatchQueue,
                        startTime: TimeInterval,
                        progress: YKNetDownloadProgress,
                        success: YKNetResponse?,
                        requestFail: YKNetErrorCompletion) throws {
        guard !taskHandlers.keys.contains(task.id) else {
            throw YKNetError(type: .taskExists(task.id))
        }
        taskHandlers[sessionTask.taskIdentifier] = YKNetTaskHandler(task: task,
                                                                    sessionTask: sessionTask,
                                                                    urlStr: urlStr,
                                                                    responseQueue: responseQueue,
                                                                    startTime: startTime,
                                                                    progress: progress,
                                                                    success: success,
                                                                    requestFail: requestFail)
    }
    
    func removeTask(url: String) {
        for handler in taskHandlers.enumerated() {
            if handler.element.value.urlStr == url {
                taskHandlers.removeValue(forKey: handler.element.key)
            }
        }
    }
    
    func worker(of event: YKNetRequestEvent) -> YKNetAfterWorker {
        var work: YKNetAfterWorker
        if let tWork = self.afterWorkers[event.name] {
            work = tWork
        } else {
            work = YKNetAfterWorker()
        }
        return work
    }
    
    func removeWorker(of event: YKNetRequestEvent) {
        afterWorkers.removeValue(forKey: event.name)
    }
    
    func handleHttpError(error: Error?,
                         data: Data?,
                         requestUrl: String,
                         event: YKNetRequestEvent,
                         requestFail: YKNetErrorCompletion) -> YKNetError? {
        if let err = error {
            let YKNetError = YKNetError.fail(err.localizedDescription,
                                             code: -1,
                                             extra: nil,
                                             responseData: data)
            self.request(error: YKNetError,
                         of: event,
                         with: requestUrl)
            requestFail?(YKNetError)
            return YKNetError
        }
        //        else if let _data = data,
        //           let YKNetError = _data.toYKNetError() {
        //            self.request(error: YKNetError,
        //                         of: event,
        //                         with: requestUrl)
        //            requestFail?(YKNetError)
        //            return YKNetError
        //        }
        return nil
    }
}

// MARK: Log
private extension YKNet {
    func log(info: String,
             extra: String? = nil) {
        DispatchQueue.main.async { [unowned self] in
            self.logTube?.log(info: info,
                              extra: extra)
        }
    }
    
    func log(warning: String,
             extra: String? = nil) {
        DispatchQueue.main.async { [unowned self] in
            self.logTube?.log(warning: warning,
                              extra: extra)
        }
    }
    
    func log(error: YKNetError,
             extra: String? = nil) {
        DispatchQueue.main.async { [unowned self] in
            self.logTube?.log(error: error,
                              extra: extra)
        }
    }
}
