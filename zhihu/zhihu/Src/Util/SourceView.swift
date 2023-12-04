//
//  SourceView.swift
//  zhihu
//
//  Created by yfm on 2023/11/10.
//

import UIKit

class SourceView: UIView {
    
    enum Source: CaseIterable {
        case zhihu
        case sina
        case netEase
        case toutiao_video
        case toutiao_hot
        case toutiao_sports
        case toutiao_cellphone
        case toutiao_finance
        case toutiao_history
        case toutiao_baby
        case toutiao_health
        case toutiao_fashion
        case toutiao_funny
        case toutiao_food
        case toutiao_travel
        case toutiao_movie
        case toutiao_宠物
        case toutiao_home
        case toutiao_edu
        case toutiao_culture
        case toutiao_story
        case toutiao_comic
        case toutiao_stock
        case toutiao_media
        case toutiao_science
        case toutiao_agriculture
        
        var title: String {
            switch self {
            case .zhihu:
                return "知乎热榜"
            case .sina:
                return "新浪财经"
            case .netEase:
                return "网易房产"
            case .toutiao_home:
                return "头条—家居"
            case .toutiao_hot:
                return "头条-热门"
            case .toutiao_video:
                return "头条-视频"
            case .toutiao_sports:
                return "头条-体育"
            case .toutiao_cellphone:
                return "头条-数码"
            case .toutiao_finance:
                return "头条-财经"
            case .toutiao_history:
                return "头条-历史"
            case .toutiao_baby:
                return "头条-育儿"
            case .toutiao_health:
                return "头条-健康"
            case .toutiao_fashion:
                return "头条-时尚"
            case .toutiao_funny:
                return "头条-搞笑"
            case .toutiao_food:
                return "头条-美食"
            case .toutiao_travel:
                return "头条-旅游"
            case .toutiao_movie:
                return "头条-电影"
            case .toutiao_宠物:
                return "头条-宠物"
            case .toutiao_edu:
                return "头条-教育"
            case .toutiao_culture:
                return "头条-人文"
            case .toutiao_story:
                return "头条-故事"
            case .toutiao_comic:
                return "头条-漫画"
            case .toutiao_stock:
                return "头条-股票"
            case .toutiao_media:
                return "头条-传媒"
            case .toutiao_science:
                return "头条-科学"
            case .toutiao_agriculture:
                return "头条-三农"
            }
        }
        
        var path: String {
            switch self {
            case .netEase, .sina, .zhihu:
                return ""
            case .toutiao_video:
                return "video"
            case .toutiao_hot:
                return "news_hot"
            case .toutiao_sports:
                return "news_sports"
            case .toutiao_cellphone:
                return "cellphone"
            case .toutiao_finance:
                return "news_finance"
            case .toutiao_history:
                return "news_history"
            case .toutiao_baby:
                return "news_baby"
            case .toutiao_health:
                return "news_health"
            case .toutiao_fashion:
                return "news_fashion"
            case .toutiao_funny:
                return "funny"
            case .toutiao_food:
                return "news_food"
            case .toutiao_travel:
                return "news_travel"
            case .toutiao_movie:
                return "movie"
            case .toutiao_宠物:
                return "宠物"
            case .toutiao_home:
                return "news_home"
            case .toutiao_edu:
                return "news_edu"
            case .toutiao_culture:
                return "news_culture"
            case .toutiao_story:
                return "news_story"
            case .toutiao_comic:
                return "news_comic"
            case .toutiao_stock:
                return "stock"
            case .toutiao_media:
                return "media"
            case .toutiao_science:
                return "science_all"
            case .toutiao_agriculture:
                return "news_agriculture"
            }
        }
    }
    
    class Model {
        var title: String = ""
        var selected: Bool = false
        var source: Source = .zhihu
    }
    
    var datasource: [Model] = []
    
    var dismiss: ((Source) -> ())?
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.8)
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()

    init(frame: CGRect, type: Source = .sina) {
        super.init(frame: frame)
        backgroundColor = .black.withAlphaComponent(0.5)
        
        let sources: [Source] = Array(Source.allCases)
        for source in sources {
            let model = Model()
            model.title = source.title
            model.source = source
            model.selected = source == type
            datasource.append(model)
        }
        makeUI()
    }
    
    func makeUI() {
        addSubview(contentView)
        contentView.addSubview(tableView)
        
        contentView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(200)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(safeAreaInsets.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        contentView.zy_x = -200
        UIView.animate(withDuration: 0.25) {
            self.contentView.zy_x = 0
        } completion: { finish in
            super.willMove(toSuperview: newSuperview)
        }
    }
    
    override func removeFromSuperview() {
        contentView.zy_x = 0
        UIView.animate(withDuration: 0.25) {
            self.contentView.zy_x = -200
        } completion: { finish in
            super.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeFromSuperview()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view?.isDescendant(of: contentView) == true {
            return false
        }
        return true
    }
}

extension SourceView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = datasource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.textLabel?.textColor = model.selected ? .red : .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datasource.forEach { $0.selected = false }
        let model = datasource[indexPath.row]
        model.selected = true
        tableView.reloadData()
        
        self.dismiss?(model.source)
        removeFromSuperview()
    }
}
