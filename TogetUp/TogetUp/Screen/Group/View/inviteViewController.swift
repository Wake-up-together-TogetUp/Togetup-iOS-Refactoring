//
//  inviteViewController.swift
//  TogetUp
//
//  Created by nayeon  on 4/12/24.
//

import UIKit
import RxSwift

class inviteViewController: BaseVC {
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
    }
    
    private func bindViewModel() {
        
    }
    
}

#Preview {
    inviteViewController()
}
