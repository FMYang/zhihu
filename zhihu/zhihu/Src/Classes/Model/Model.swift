//
//  Model.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import Foundation

struct Item: Codable {
    var title: String?
    var url: String?
    var docid: String?
}

// 新浪财经详情
struct NewsDetail: Codable {
    var result: Result
}

struct Result: Codable {
    var data: [NewsData?]
}

struct NewsData: Codable {
    var content: String?
}

// 头条详情
struct ToutiaoDetail: Codable {
    var data: ToutiaoDetailData?
}

struct ToutiaoDetailData: Codable {
    var content: String?
    var image_detail: [NewsDetailImage]?
    var video_count: Int?
}

let detailImageWidth = Double(kScreenWidth - 20)
class NewsDetailImage: Codable {
    var width: Double = 0.0
    var height: Double = 0.0
    var uri: String = ""
    var url: String = ""
    
    // 根据设备重新设置图片宽高
    func fitWidthAndHeight(width originWidth: Double,
                                    height originHeight: Double) {
        width = detailImageWidth
        height = width * originHeight / originWidth
    }
}

