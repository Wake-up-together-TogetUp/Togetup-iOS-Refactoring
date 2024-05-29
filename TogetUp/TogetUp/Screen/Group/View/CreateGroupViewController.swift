//
//  CreateGroupViewController.swift
//  TogetUp
//
//  Created by nayeon  on 2/12/24.
//

import UIKit
import SnapKit

class CreateGroupViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel = CreateGroupViewModel()
    var customView = CreateGroupView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        navigationItem.title = "그룹 개설하기"
        navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem =  UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(saveButtonTapped))
        view.backgroundColor = .white
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
        
        customView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        customView.addMissionButton.addTarget(self, action: #selector(addMissionButtonTapped), for: .touchUpInside)
        customView.groupIntroTextView.text = viewModel.groupIntro
        
    }
    
    // MARK: - Button Actions
    @objc private func addAlarmButtonTapped() {
       
    }
    
    @objc private func cancelButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        
    }
}
