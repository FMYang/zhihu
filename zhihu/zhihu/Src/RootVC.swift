//
//  RootVC.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import UIKit
import Combine
import SnapKit

class RootVC: UIViewController {
    
    var subscriptions = Set<AnyCancellable>()
    var page = 1 {
        didSet {
            ListAPI.page = page
        }
    }
    
    var datasource: [Item] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(ListCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "知乎"
        configNavation()
        makeUI()
        addRefresh()
    }
    
    func configNavation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        // hide bottom line
        appearance.shadowImage = UIImage.imageWithColor(color: .white)
        appearance.backgroundImage = UIImage.imageWithColor(color: .white)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func addRefresh() {
        self.tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.page = 1
            self?.loadData()
        })

        self.tableView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            self?.loadData()
        })

        self.tableView.headRefreshControl.beginRefreshing()
    }
    
    func loadData() {
        APIService.request(target: ListAPI.list).responseDecodable(of: [Item].self) { [weak self] response in
            switch response.result {
            case .success(let items):
                if self?.page == 1 {
                    self?.datasource.removeAll()
                }
                self?.datasource += items
                self?.page += 1
                
                if items.count == 0 {
                    self?.tableView.footRefreshControl.endRefreshingAndNoLongerRefreshing(withAlertText: "没有数据了")
                }
            case .failure(let err):
                print(err)
            }
            
            self?.tableView.headRefreshControl.endRefreshing()
            self?.tableView.footRefreshControl.endRefreshing()
        }
        
        //        APIService.request(target: ListAPI.list,
        //                           type: [Item].self)
        //        .sink { response in
        //            switch response.result {
        //            case .success(let items):
        //                print(items)
        //            case .failure(let err):
        //                print(err)
        //            }
        //        }
        //        .store(in: &subscriptions)
    }
    
    func makeUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RootVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListCell
        cell.titleLabel.text = item.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datasource[indexPath.row]
        if let url = item.url {
            let vc = IWebViewController(urlPath: url)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UIImage {
    class func imageWithColor(color:UIColor) -> UIImage?{
        let rect = CGRect.init(x:0, y:0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
