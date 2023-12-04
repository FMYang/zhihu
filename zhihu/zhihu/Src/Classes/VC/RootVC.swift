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
    
    var source: SourceView.Source = .zhihu {
        didSet {
            sourceButton.setTitle(source.title, for: .normal)
            loadData()
        }
    }
    
    var curDate = "" {
        didSet {
            datasource = []
            dateButton.setTitle(curDate, for: .normal)
            loadData()
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
    
    lazy var sourceButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitle("知乎热榜", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(sourceAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var dateButton: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.setTitle("\(curDate)", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.addTarget(self, action: #selector(jumpAction), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "要闻"
        configNavation()
        makeUI()
        addRefresh()
        curDate = getCurDate()
        addGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dateButton.isHidden = true
        sourceButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dateButton.isHidden = false
        sourceButton.isHidden = false
    }
    
    func addGesture() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGeture))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func swipeGeture() {
        sourceAction()
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
        
        navigationController?.navigationBar.addSubview(sourceButton)
        navigationController?.navigationBar.addSubview(dateButton)
        
        dateButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(100)
            make.top.bottom.equalToSuperview()
        }
        
        sourceButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(100)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func addRefresh() {
        self.tableView.bindGlobalStyle(forHeadRefreshHandler: { [weak self] in
            self?.loadData()
        })
    }
        
    func loadData() {
        datasource = []
        APIService.request1(target: ListAPI.list(curDate, source),
                           type: [Item].self) { [weak self] response in
            switch response.result {
            case .success(let items):
                self?.datasource = items
            case .failure(let err):
                self?.view.showToast("\(err.localizedDescription)")
            }
            self?.tableView.headRefreshControl.endRefreshing()
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
        }
        navigationController?.view.addSubview(dateView)
    }
    
    @objc func sourceAction() {
        let sourceView = SourceView(frame: UIScreen.main.bounds, type: source)
        sourceView.dismiss = { [weak self] source in
            if self?.source != source {
                self?.source = source
            }
        }
        sourceView.tag = 1001
        navigationController?.view.addSubview(sourceView)
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
        if source == .sina {
            let vc = NewDetailVC(item: item)
            navigationController?.pushViewController(vc, animated: true)
        } else if source == .zhihu || source == .netEase {
            if let url = item.url {
                let vc = IWebViewController(urlPath: url)
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = ToutiaoDetailVC(item: item)
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
