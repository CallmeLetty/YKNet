//
//  ArminExecutor.swift
//  Pods
//
//  Created by LYY on 2021/11/9.
//

import Foundation

extension YKNet {
    func requestSuccess(of event: YKNetRequestEvent,
                        startTime: TimeInterval,
                        with url: String) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.ykNet(self,
                                 requestSuccess: event,
                                 startTime: startTime,
                                 url: url)
        }
    }
    
    func request(error: YKNetError,
                 of event: YKNetRequestEvent,
                 with url: String) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else {
                return
            }
            self.delegate?.ykNet(self,
                                 requestFail: error,
                                 event: event,
                                 url: url)
        }
    }
    
    static let defaultHTTPHeaders: [String : String] = {
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        let acceptLanguage = Locale.preferredLanguages
                                   .prefix(6)
                                   .enumerated()
                                   .map { index, languageCode in
                                       let quality = 1.0 - (Double(index) * 0.1)
                                       return "\(languageCode);q=\(quality)"
                                   }
                                   .joined(separator: ", ")

        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

                    let osName: String = {
                        #if os(iOS)
                            return "iOS"
                        #elseif os(watchOS)
                            return "watchOS"
                        #elseif os(tvOS)
                            return "tvOS"
                        #elseif os(macOS)
                            return "OS X"
                        #elseif os(Linux)
                            return "Linux"
                        #else
                            return "Unknown"
                        #endif
                    }()

                    return "\(osName) \(versionString)"
                }()

                let arminVersion: String = {
                    guard let arInfo = Bundle(for: YKNet.self).infoDictionary,
                        let build = arInfo["CFBundleShortVersionString"]
                    else { return "Unknown" }

                    return "YKNet/\(build)"
                }()

                return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(arminVersion)"
            }

            return "YKNet"
        }()

        return [
            "Accept-Encoding": acceptEncoding,
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent
        ]
    }()
}


extension String {
    //????????????url??????????????????url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //???????????????url??????????????????url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
}
}
