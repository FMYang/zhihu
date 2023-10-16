//
//  ListTarget.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation
import Alamofire

enum ListAPI {
case list(String)
}

extension ListAPI: APITarget {
    var host: String {
        "https://raw.githubusercontent.com"
    }
    
    var path: String {
        switch self {
        case .list(let date):
            //        "/FMYang/zhihu-trending-hot-questions/master/raw/\(date).json"
            return "/aishang-gif/zhihu-trending-hot-questions/master/raw/\(date).json"
        }
    }
    
    var params: [String : Any]? {
        return ["test": "1"]
    }
}
