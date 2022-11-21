//
//  ViewController.swift
//  Sample
//
//  Created by CallmeLetty on 2020/5/25.
//  Copyright © 2020 CallmeLetty. All rights reserved.
//

import UIKit
import YKNet

class ViewController: UIViewController {
    lazy var client = YKNet(delegate: self,
                            logTube: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        getRequest()
    }
    
    func getRequest() {
        let url = "https://www.tianqiapi.com/api"
        let event = YKNetRequestEvent(name: "Sample-get")
        let task = YKNetRequestTask(event: event,
                                 type: .http(.get, url: url),
                                 timeout: .low,
                                 parameters: ["appid": "23035354",
                                              "appsecret": "8YvlPNrz",
                                              "version": "v9",
                                              "cityid": "0",
                                              "city": "%E9%9D%92%E5%B2%9B",
                                              "ip": "0",
                                              "callback": "0"])
        
        client.request(task: task, success: YKNetResponse.json({ (json) in
            print("weather json: \(json.description)")
        })) { (error) -> YKNetRetryOptions in
            print("error: \(error.localizedDescription)")
            return .resign
        }
    }
    
    func postRequest() {
        let url = ""
        let event = YKNetRequestEvent(name: "Sample-post")
        let parameters: [String: Any]? = nil
        let headers: [String: String]? = nil
        let task = YKNetRequestTask(event: event,
                               type: .http(.post, url: url),
                               timeout: .low,
                               header: headers,
                               parameters: parameters)
        
        client.request(task: task, success: YKNetResponse.json({ (json) in
            print("weather json: \(json.description)")
        })) { (error) -> YKNetRetryOptions in
            print("error: \(error.localizedDescription)")
            return .resign
        }
    }
    
    func uploadRequest() {
        
    }
    
    func downloadRequest() {
        let urlStr = "https://convertcdn.netless.link/publicFiles.zip"
        let event = YKNetRequestEvent(name: "download-image")
        let obj = YKNetDownloadObject(targetDirectory: "/Users/doublecircle/Desktop/YKNetmin_local")
        let task = YKNetDownloadTask(event: event,
                                  object: obj,
                                  url: urlStr)
        client.download(task: task,
                        progress: { progress in
            print("----------Progress: \(progress)")
        }, success: YKNetResponse.string({ finalPath in
            print("----final path: \(finalPath)")
        })) { (error) -> YKNetRetryOptions in
            print("error: \(error.localizedDescription)")
            return .resign
        }
    }
}

// MARK: - YKNetDelegate
extension ViewController: YKNetDelegate {
    func ykNet(_ client: YKNet,
               requestSuccess event: YKNetRequestEvent,
               startTime: TimeInterval, url: String) {
        print("request success, event: \(event.description), url: \(url)")
    }
    
    func ykNet(_ client: YKNet,
               requestFail error: YKNetError,
               event: YKNetRequestEvent, url: String) {
        print("request error, event: \(event.description), error: \(error.localizedDescription), url: \(url)")
    }
}

// MARK: - YKNetLogTube
extension ViewController: YKNetLogTube {
    func log(info: String,
             extra: String?) {
        print("info: \(info), extra: \(extra ?? "nil")")
    }
    
    func log(warning: String,
             extra: String?) {
        print("warning: \(warning), extra: \(extra ?? "nil")")
    }
    
    func log(error: YKNetError, extra: String?) {
        print("error: \(error), extra: \(extra ?? "nil")")
    }
}
