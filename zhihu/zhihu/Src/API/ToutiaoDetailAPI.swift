//
//  ToutiaoDetailAPi.swift
//  zhihu
//
//  Created by yfm on 2023/11/14.
//

import Foundation
import Alamofire

enum ToutiaoDetailAPI {
case detail(String)
}

extension ToutiaoDetailAPI: APITarget {
    var host: String {
        "https://a3.pstatp.com"
    }
    
    var path: String {
        switch self {
        case let .detail(docid):
            return "/article/content/lite/14/1/\(docid)/\(docid)/1/0"
        }
    }
}
