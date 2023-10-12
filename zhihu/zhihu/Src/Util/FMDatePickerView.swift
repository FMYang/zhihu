//
//  FMDatePickerView.swift
//  FMAccountBook
//
//  Created by yfm on 2023/3/15.
//

import UIKit

let kDatePickerHeight: Double = 250.0
let kPickerHeight: Double = 290.0

let selectedColor = UIColor.color(hex: "#FA5252")
let bgColor = UIColor.color(hex: "#F6F6F6")

class FMDatePickerView: UIView {
    
    var confirmBlock: ((Int, Int, Int)->())?
    
    var year = 0
    var month = 0
    var day = 0
    var years = [Int]()
    var months = [Int]()
    var days = [Int]()

    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kPickerHeight))
        view.backgroundColor = bgColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        return btn
    }()
    
    lazy var doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        return btn
    }()
    
    lazy var datePicker: UIPickerView = {
        let view = UIPickerView(frame: .zero)
        view.backgroundColor = bgColor
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    init(date: String) {
        super.init(frame: UIScreen.main.bounds)
        
        buildData()
        makeUI()
        
        let array = date.components(separatedBy: "-")
        year = Int(array[0]) ?? 2023
        month = Int(array[1]) ?? 1
        day = Int(array[2]) ?? 1

        let yearIndex = years.firstIndex(of: year) ?? 0
        let monthIndex = months.firstIndex(of: month) ?? 0
        let dayIndex = days.firstIndex(of: day) ?? 0
        datePicker.selectRow(yearIndex, inComponent: 0, animated: false)
        datePicker.selectRow(monthIndex, inComponent: 1, animated: false)
        datePicker.selectRow(dayIndex, inComponent: 2, animated: false)
    }
    
    @available(*, unavailable)
    init() {
        fatalError()
    }
    
    @available(*, unavailable)
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildData() {
        year = Calendar.currentYear() ?? 2023
        month = Calendar.currentMonth() ?? 1
        day = Calendar.currentDay() ?? 1
        years = Array(year-2...year)
        months = Array(1...12)
        days = Calendar.getDaysArray(year: year, month: month)
    }

    @objc func dismiss() {
        removeFromSuperview()
    }
    
    @objc func confirm() {
        confirmBlock?(year, month, day)
        dismiss()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        containerView.zy_y = kScreenHeight
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.containerView.zy_y = kScreenHeight - kPickerHeight + kSafeAreaInsets.bottom
        }, completion: { finish in
            super.willMove(toSuperview: newSuperview)
        })
    }
    
    override func removeFromSuperview() {
        containerView.zy_y = kScreenHeight - kPickerHeight + kSafeAreaInsets.bottom
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.containerView.zy_y = kScreenHeight
        }, completion: { finish in
            super.removeFromSuperview()
        })
    }
    
    func makeUI() {
        addSubview(contentView)
        addSubview(containerView)
        containerView.addSubview(cancelButton)
        containerView.addSubview(doneButton)
        containerView.addSubview(datePicker)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
}

extension FMDatePickerView {
    func resetMonth() {
        datePicker.selectRow(0, inComponent: 1, animated: true)
        month = 1
    }
    
    func resetDay() {
        days = Calendar.getDaysArray(year: year, month: month)
        datePicker.reloadComponent(2)
        datePicker.selectRow(0, inComponent: 2, animated: true)
        day = 1
    }
}

extension FMDatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else {
            return days.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])" + "年"
        } else if component == 1 {
            return String(format: "%2d", months[row]) + "月"
        } else {
            return String(format: "%2d", days[row]) + "日"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            year = years[row]
        } else if component == 1 {
            month = months[row]
        } else {
            day = days[row]
        }
        
        if component == 0 {
            resetMonth()
            resetDay()
        }

        if component == 1 {
            resetDay()
        }
    }
}
