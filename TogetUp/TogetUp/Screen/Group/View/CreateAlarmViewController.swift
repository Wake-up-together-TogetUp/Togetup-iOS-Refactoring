//
//  CreateAlarmViewController.swift
//  TogetUp
//
//  Created by nayeon  on 3/26/24.
//

import UIKit
import RxSwift

class CreateAlarmViewController: UIViewController {
    private var createAlarmView = CreateAlarmView()
    private let viewModel = CreateAlarmViewModel()
    private let disposeBag = DisposeBag()
    var groupName: String = ""
    var groupIntro: String = ""
    var missionId: Int = 2
    var missionObjectId: Int? = 1
    
    override func loadView() {
        super.loadView()
        createAlarmView = CreateAlarmView()
        view = createAlarmView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonTapped))
    }
    
    private func bindViewModel() {
        let weekdaySelection = Observable.merge(
            createAlarmView.weekdayButtons.map { button in
                button.rx.tap.map { _ in
                    return self.createAlarmView.weekdayButtons.map { $0.isSelected }
                }
            }
        ).startWith(createAlarmView.weekdayButtons.map { $0.isSelected })
        
        let input = CreateAlarmViewModel.Input(
            alarmName: createAlarmView.alarmNameTextField.rx.text.orEmpty.asObservable(),
            timeSelected: createAlarmView.timePicker.rx.date.asObservable(),
            weekdaySelection: weekdaySelection,
            vibrationEnabled: createAlarmView.vibrationToggle.rx.isOn.asObservable(),
            createButtonTapped: createAlarmView.openedButton.rx.tap.asObservable(),
            groupName: Observable.just(groupName),
            groupIntro: Observable.just(groupIntro),
            missionId: Observable.just(missionId),
            missionObjectId: Observable.just(missionObjectId)
        )
        
        let output = viewModel.transform(input: input)
        
        output.isCreateButtonEnabled
            .bind(to: createAlarmView.openedButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.createAlarmResponse
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let createGroupResponse):
                    print("그룹 생성 성공: \(createGroupResponse)")
                    // TODO: 완료 후 화면(캘린더)이동
                case .failure(let error):
                    let errorMessage = NetworkManager().errorMessage(for: error)
                    print("에러: \(errorMessage)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
