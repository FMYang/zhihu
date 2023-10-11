//
//  IWebViewController.swift
//  iGithub
//
//  Created by yfm on 2019/1/10.
//  Copyright © 2019年 com.yfm.www. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class IWebViewController: UIViewController {

    var webViewObserve: NSKeyValueObservation?

    var webTitle: String?

    lazy var backButtonItem: UIBarButtonItem = {
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        backButton.setImage(UIImage(named: "icon-back-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        return item
    }()

    lazy var closeButtonItem: UIBarButtonItem = {
        let closeButton = UIButton()
        closeButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        closeButton.setImage(UIImage(named: "icon-delete"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        let item = UIBarButtonItem(customView: closeButton)
        return item
    }()

    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        return view
    }()

    lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.trackTintColor = UIColor.white
        view.progressTintColor = .red
        return view
    }()
    
    deinit {
        webViewObserve?.invalidate()
    }

    convenience init(urlPath: String?) {
        self.init()

        guard let _urlPath = urlPath, let _url = URL(string: _urlPath) else {
            return
        }
        webView.load(URLRequest(url: _url))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []

        title = webTitle

        layoutUI()

        navigationItem.leftBarButtonItems = [backButtonItem]

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        webViewObserve = webView.observe(\.estimatedProgress, options: [.old, .new]) { [weak self] webView, change in
            let progress = Float(change.newValue ?? 0.0)
            self?.progressView.setProgress(progress, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - function
    func layoutUI() {
        self.view.addSubview(progressView)
        self.view.addSubview(webView)
        progressView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }

        webView.snp.makeConstraints { (make) in
            make.top.equalTo(progressView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - action
    @objc func closeAction() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backAction() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension IWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.progress = 0.0
        title = webTitle ?? webView.title
         if webView.canGoBack {
            navigationItem.leftBarButtonItems = [backButtonItem, closeButtonItem]
        } else {
            navigationItem.leftBarButtonItems = [backButtonItem]
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progressView.progress = 0.0
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("commit \(webView.canGoBack)")
        webView.allowsBackForwardNavigationGestures = webView.canGoBack
        navigationController?.interactivePopGestureRecognizer?.isEnabled = !webView.canGoBack
    }
}

extension IWebViewController: UIGestureRecognizerDelegate {
}
