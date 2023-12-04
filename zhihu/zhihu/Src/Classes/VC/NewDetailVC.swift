//
//  NewDetailVC.swift
//  zhihu
//
//  Created by yfm on 2023/11/10.
//

import UIKit
import WebKit

class NewDetailVC: UIViewController {
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .white
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return webView
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
    
    var articleTitle = ""
    var docid = ""
    var url = ""
    
    init(item: Item) {
        super.init(nibName: nil, bundle: nil)
        self.articleTitle = item.title ?? ""
        self.docid = item.docid ?? ""
        self.url = item.url ?? ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadData()
    }
    
    func loadData() {
        activityView.startAnimating()
        APIService.request1(target: DetailAPI.detail(self.docid, self.url),
                            type: NewsDetail.self) { [weak self] response in
            self?.activityView.stopAnimating()
            switch response.result {
            case .success(let detail):
                if let content = detail.result.data[0]?.content {
                    self?.loadHtml(content: content)
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    
    func loadHtml(content: String) {
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
            <h3>\(articleTitle)</h3>
            \(content)
        </body>
        </html>
        """

        webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
}
