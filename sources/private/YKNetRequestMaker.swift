//
//  YKNetRequestGenerator.swift
//  YKNet
//
//  Created by LYY on 2021/11/22.
//

import Foundation

class YKNetRequestMaker {
    func makeRequest(urlstr: String,
                     timeout: TimeInterval,
                     method: YKNetHTTPMethod,
                     headers: [String: String]?,
                     params: [String: Any]?) throws -> URLRequest {

        // url
        guard let url = makeUrl(urlstr: urlstr,
                                httpMethod: method,
                                parameters: params) else {
            throw YKNetError(type: .invalidParameter("params"))
        }
        
        var request = URLRequest(url: url,
                                 timeoutInterval: timeout)
        request.httpMethod = method.stringValue
        // header
        request.makeHeaders(headers: headers)
        
        // body
        do{
            try request.makeBody(httpMethod: method,
                                 parameters: params)
        } catch {
            throw error as! YKNetError
        }
        
        return request
    }
    
    func makeDataRequest(urlstr: String,
                         timeout: TimeInterval,
                         params: [String: Any]?,
                         uploadObject: YKNetUploadObject) throws -> URLRequest {
        let method = YKNetHTTPMethod.post
        
        // url
        guard let url = makeUrl(urlstr: urlstr,
                                httpMethod: method,
                                parameters: params) else {
            throw YKNetError(type: .invalidParameter("params"))
        }
        
        let multiRequest = ArMultipartFormDataRequest(method: method,
                                                      url: url,
                                                      timeout: .custom(timeout))
        
        multiRequest.addDataField(named: uploadObject.fileName,
                                  data: uploadObject.fileData,
                                  mimeType: uploadObject.mime.text)
        return multiRequest.toURLRequest()
    }
    
    func makeUrl(urlstr: String,
                 httpMethod: YKNetHTTPMethod,
                 parameters: Dictionary<String, Any>?) -> URL? {
        var urlString = urlstr
        guard [YKNetHTTPMethod.get,
               YKNetHTTPMethod.head,
               YKNetHTTPMethod.delete].contains(httpMethod),
              let params = parameters else {
            return URL(string:urlString.urlEncoded())
        }
        
        guard let url = URL(string:urlString.urlEncoded()) else {
            return nil
        }

        let JSONArr: NSMutableArray = NSMutableArray()
//        for key in params.keys {
//            let JSONString = ("\(key)\("=")\(params[key] as! String)")
//            JSONArr.add(JSONString)
//        }
        let paramStr = JSONArr.componentsJoined(by:"&")
        urlString.append("?" + paramStr)

        return URL(string:urlString.urlEncoded())
    }
}
