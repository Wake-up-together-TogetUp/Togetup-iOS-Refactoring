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
}
