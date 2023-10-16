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
    var curDate = "" {
        didSet {
            jumpButton.setTitle(curDate, for: .normal)
            datasource = []
            DispatchQueue.main.async {
                self.tableView.headRefreshControl.beginRefreshing()
            }
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
    
    lazy var jumpButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitle("\(curDate)", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(jumpAction), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "知乎热榜"
        configNavation()
        makeUI()
        addRefresh()
        curDate = getCurDate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jumpButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jumpButton.isHidden = false
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
        
        navigationController?.navigationBar.addSubview(jumpButton)
        jumpButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func getCurDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func addRefresh() {
        self.tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.loadData()
        })
    }
    
    func loadData() {
        APIService.request(target: ListAPI.list(curDate),
                           type: [Item].self) { [weak self] response in
            switch response.result {
            case .success(let items):
                self?.datasource = items
            case .failure(let err):
                print(err)
            }
            
            self?.tableView.headRefreshControl.endRefreshing()
        }
    }
    
    func makeUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RootVC {
    @objc func jumpAction() {
        let dateView = FMDatePickerView(date: curDate)
        dateView.confirmBlock = { [weak self] year, month, day in
            let text = String(format: "%d-%02d-%02d", year, month, day)
            self?.curDate = text
        }
        navigationController?.view.addSubview(dateView)
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
