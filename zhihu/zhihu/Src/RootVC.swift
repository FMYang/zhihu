//
//  RootVC.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import UIKit
import Combine
import SnapKit
import Alamofire

class RootVC: UIViewController {
    
    var subscriptions = Set<AnyCancellable>()
    
    var useGitlab: Bool = true {
        didSet {
            changeButton.setTitle(useGitlab ? "gitlab" : "github", for: .normal)
        }
    }
    
    var curDate = "" {
        didSet {
            jumpButton.setTitle(curDate, for: .normal)
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
    
    lazy var changeButton: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitle("gitlab", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self, action: #selector(changeAction), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "知乎热榜"
        configNavation()
        makeUI()
        addRefresh()
        curDate = getCurDate()
        tableView.headRefreshControl.beginRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        jumpButton.isHidden = true
        changeButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        jumpButton.isHidden = false
        changeButton.isHidden = false
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
        navigationController?.navigationBar.addSubview(changeButton)
                
        jumpButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.top.bottom.equalToSuperview()
        }
        
        changeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(100)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func addRefresh() {
        self.tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            guard let self = self else { return }
            self.loadData(refresh: true)
        })
        
        self.tableView.bindGlobalStyle(forFootRefreshHandler: { [weak self] in
            guard let self = self else { return }
            self.curDate = self.getNextDate()
            self.loadData(refresh: false)
        })
    }
    
    func loadData(refresh: Bool) {
        APIService.request(target: ListAPI.list(curDate, useGitlab),
                           type: [Item].self) { [weak self] response in
            switch response.result {
            case .success(let items):
                if refresh {
                    self?.datasource = items
                } else {
                    self?.datasource += items
                }
            case .failure(let err):
                self?.view.showToast("\(err.localizedDescription)")
            }
            
            self?.tableView.headRefreshControl.endRefreshing()
            self?.tableView.footRefreshControl.endRefreshing()
        }
    }
    
    func getCurDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func getNextDate() -> String {
        let currentDateStr = self.curDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let currentDate = formatter.date(from: currentDateStr)
        if let date = currentDate, let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) {
            let str = formatter.string(from: nextDay)
            return str
        } else {
            return currentDateStr
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
            self?.tableView.headRefreshControl.beginRefreshing()
        }
        navigationController?.view.addSubview(dateView)
    }
    
    @objc func changeAction() {
        useGitlab.toggle()
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
