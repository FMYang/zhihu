//
//  ListCell.swift
//  zhihu
//
//  Created by yfm on 2023/10/10.
//

import UIKit

class ListCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray.withAlphaComponent(0.3)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        addSubview(titleLabel)
        addSubview(lineView)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
