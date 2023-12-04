//
//  DetailAPI.swift
//  zhihu
//
//  Created by yfm on 2023/11/10.
//

import Foundation
import Alamofire

enum DetailAPI {
case detail(String, String)
}

extension DetailAPI: APITarget {
    var host: String {
        "https://app.finance.sina.com.cn" //新浪详情
    }
    
    var path: String {
        switch self {
        case let .detail(docid, url):
            return "/toutiao/content?docid=\(docid)&url=\(url)"
        }
    }
}
