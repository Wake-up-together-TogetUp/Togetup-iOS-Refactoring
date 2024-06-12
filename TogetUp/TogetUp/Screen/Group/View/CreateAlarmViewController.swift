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
            createButtonTapped: createAlarmView.openedButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.isCreateButtonEnabled
            .bind(to: createAlarmView.openedButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.createAlarmResponse
            .subscribe(onNext: { [weak self] response in
                print("@@@@@")
                switch response {
                case .success(let createGroupResponse):
                    print("그룹 생성 성공: \(createGroupResponse)")
                    // TODO: 완료 후 화면(캘린더)이동
                case .failure(let error):
                    let errorMessage = self?.errorMessage(for: error) ?? "알 수 없는 에러가 발생했습니다."
                    print("에러: \(errorMessage)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func errorMessage(for error: NetWorkingError) -> String {
        switch error {
        case .network, .noInternetConnection:
            return "네트워크 연결이 원활하지 않습니다."
        case .server(let statusCode):
            return "서버 에러가 발생했습니다. 에러 코드: \(statusCode)"
        default:
            return "알 수 없는 에러가 발생했습니다."
        }
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
