//
//  ToutiaoDetailVC.swift
//  zhihu
//
//  Created by yfm on 2023/11/14.
//

import UIKit
import WebKit
import ZFPlayer
import FDFullscreenPopGesture

class ToutiaoDetailVC: UIViewController {
    
    var item: Item!
    var html: String = ""
    var detail: ToutiaoDetail?
    var player: ZFPlayerController?
    
    lazy var webview: WKWebView = {
        let view = WKWebView.init(frame: .zero)
        view.backgroundColor = .white
        
        self.view.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.tintColor = .gray
        
        view.addSubview(activityView)
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        return activityView
    }()
    
    // MARK: - life cycle
    init(item: Item) {
        super.init(nibName: nil, bundle: nil)
        self.item = item
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        loadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if (player?.isFullScreen == true) {
            return .landscape
        }
        return .portrait
    }
    // MARK: - function

    func loadData() {
        activityView.startAnimating()
        APIService.request1(target: ToutiaoDetailAPI.detail(item.docid ?? ""), type: ToutiaoDetail.self) { [weak self] response in
            self?.activityView.stopAnimating()
            switch response.result {
            case .success(let data):
                self?.detail = data
                if let videoCount = data.data?.video_count, videoCount > 0 {
                    self?.loadRemote()
                } else {
                    self?.loadLocalHtml(content: data.data?.content ?? "")
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func loadRemote() {
        let url = URL(string: "https://www.ixigua.com/\(item.docid ?? "")")!
        webview.load(URLRequest(url: url))
    }
    
    func loadLocalHtml(content: String) {
        html = content
        replaceAllImgTag(html: &html)
        
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body {
                    font-size: 18px;
                    padding: 5px;
                }
                a {
                    color: black;
                    text-decoration: none;
                }
                h3 {
                    text-align:left;
                    font-size:18;
                    font-weight:bold;
                    color:#333333;
                    margin-bottom:5px;
                }
                .article-img {
                    max-width: 100%;
                    height: auto;
                }
            </style>
        </head>
        <body>
            <h3>\(item.title ?? "")</h3>
            \(html)
        </body>
        </html>
        """

        webview.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    func replaceAllImgTag(html: inout String) {
        do {
            if let start = html.range(of: "<header>"), let end = html.range(of: "</header>") {               
                html = html.replacingCharacters(in: start.lowerBound..<end.lowerBound, with: "")
            }
            
            // 获取所有a标签
            let regularExpression = "<a\\b[^>]*\\bhref\\s*=\\s*(\"[^\"]*\"|'[^']*')[^>]*>((?:(?!</a).)*)</a\\s*>"
            let regular = try NSRegularExpression(pattern: regularExpression, options: [])
            let result: [NSTextCheckingResult] = regular.matches(in: html, options: [], range: NSRange(location: 0, length: html.count))

            var aTags: [String] = []
            for x in result {
                let startIndex = html.index(html.startIndex, offsetBy: x.range.location)
                let endIndex = html.index(startIndex, offsetBy: x.range.length)
                let aTag = html[startIndex..<endIndex]
                aTags.append(String(aTag))
            }
            
            // 占位图替换为可显示的<img>标签
            if let images = detail?.data?.image_detail {
                for image in images {
                    for tag in aTags {
                        let src = image.uri.replacingOccurrences(of: "/", with: "%2F")

                        if tag.contains(src) {
                            let newTag = "<p style=\"text-align:center\"><img class='article-img' src=\(image.url)></p>"
                            html = html.replacingOccurrences(of: tag, with: newTag)
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
    }

}
