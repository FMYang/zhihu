//
//  ListTarget.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation
import Alamofire

enum ListAPI {
case list(String, Bool)
}

extension ListAPI: APITarget {
    var host: String {
        switch self {
        case let .list(_, isGitlab):
            return isGitlab ? "https://gitlab.com" : "https://raw.githubusercontent.com"
        }
    }
    
    var path: String {
        switch self {
        case .list(let date, let isGitlab):
            if isGitlab {
                return "/FMYang/zhihu-trending-hot-questions/-/raw/main/raw/\(date).json?ref_type=heads"
            } else {
                return "/aishang-gif/zhihu-trending-hot-questions/master/raw/\(date).json"
//                return "/FMYang/zhihu-trending-hot-questions/master/raw/\(date).json"
            }
        }
    }
}
