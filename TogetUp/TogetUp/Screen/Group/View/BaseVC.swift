//
//  BaseVC.swift
//  TogetUp
//
//  Created by nayeon  on 2/14/24.
//

import UIKit

class BaseVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 공통적으로 필요한 설정
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        // 네비게이션 바 설정
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.isTranslucent = false
    }
}
