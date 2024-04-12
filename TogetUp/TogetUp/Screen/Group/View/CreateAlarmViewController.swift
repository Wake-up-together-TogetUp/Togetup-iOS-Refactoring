//
//  CreateAlarmViewController.swift
//  TogetUp
//
//  Created by nayeon  on 3/26/24.
//

import UIKit

class CreateAlarmViewController: BaseVC {
    private let createAlarmView: CreateAlarmView = CreateAlarmView()
    
    override func loadView() {
        self.view = createAlarmView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    override func setupUI() {
        createAlarmView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
}
