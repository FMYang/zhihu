//
//  ListTarget.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation
import Alamofire

enum ListAPI {
    case list(String, SourceView.Source)
}

extension ListAPI: APITarget {
    var host: String {
        switch self {
        case .list(_, _):
            "https://gitlab.com"
        }
    }
    
    var path: String {
        switch self {
        case let .list(date, source):
            switch source {
            case .zhihu:
                return "/FMYang/zhihu-trending-hot-questions/-/raw/main/raw/\(date).json?ref_type=heads"
            case .sina:
                return "/FMYang/sina/-/raw/main/raw/\(date).json?ref_type=heads"
            case .netEase:
                return "/FMYang/163/-/raw/main/raw/\(date).json?ref_type=heads"
            default:
                return "/FMYang/toutiao/-/raw/main/raw/\(source.path)/\(date).json?ref_type=heads".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            }
        }
    }
}
