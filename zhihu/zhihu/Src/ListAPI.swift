//
//  ListTarget.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation
import Alamofire

enum ListAPI {
case list
}

extension ListAPI: APITarget {
    static var page = 1
    static func date() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentTime = formatter.string(from: date)
        if page == 1 {
            return currentTime
        } else {
            // 获取前面第n天的时间，例如page=2，则获取前1天的时间
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.day = -(page-1)
            guard let previousDay = calendar.date(byAdding: dateComponents, to: Date()) else {
                return currentTime
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let previousDayString = dateFormatter.string(from: previousDay)
            return previousDayString
        }
    }
    
    var host: String {
        "https://raw.githubusercontent.com/FMYang/zhihu-trending-hot-questions/master/raw/\(Self.date()).json"
    }
    
    var path: String {
        ""
    }
    
    var params: [String : Any]? {
        nil
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        nil
    }
    
    var timeoutInterval: TimeInterval? {
        nil
    }
}
