//
//  GroupJoinAlarmViewController.swift
//  TogetUp
//
//  Created by nayeon  on 7/21/24.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class GroupJoinAlarmViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = GroupJoinAlarmViewModel()
    private let disposeBag = DisposeBag()
    var roomId: Int = 0
    var icon: String = ""
    var missionKr: String = ""
    var missionId: Int = 2
    var missionObjectId: Int? = 1
    private let vibrationToggle = UISwitch()
    
    lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.backgroundColor = UIColor.white
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 2
        return view
    }()
    
    private let weekdayButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let alarmLabel: UILabel = {
        let label = UILabel()
        label.text = "알람명"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return label
    }()
    
    private let vibrationLabel: UILabel = {
        let label = UILabel()
        label.text = "진동"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return label
    }()
    
    private var alarmNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "알람"
        textField.borderStyle = .none
        textField.textAlignment = .right
        return textField
    }()
    
    private let missionSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "미션"
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 18)
        return label
    }()
    
    private let missionSubLabel: UILabel = {
       let label = UILabel()
        label.text = "방장만 수정할 수 있어요"
        label.textColor = .lightGray
        return label
    }()
    
    private let addMissionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "secondary025")
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return button
    }()
    
    private let circleView: UIView = {
        let circleView = UIView()
        circleView.backgroundColor = UIColor.white
        circleView.layer.cornerRadius = 30
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1).cgColor
        return circleView
    }()
    
    private var missionImageLabel: UILabel = {
        let img = UILabel()
        img.text = "⏰"
        img.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 36)
        return img
    }()
    
    private var missionTextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "미션 내용"
        return label
    }()
    
    private let openedButton: UIButton = {
       let button = UIButton()
        button.setTitle("참여하기", for: .normal)
        button.backgroundColor = UIColor(named: "primary400")
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
        return button
    }()
    
    var weekdayButtons: [UIButton] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "chevron-left"), style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.title = "알람 설정"
        
        missionImageLabel.text = icon
        missionTextLabel.text = missionKr
        
        view.addSubview(timePicker)
        view.addSubview(containerView)
        containerView.addSubview(weekdayButtonsStackView)
        containerView.addSubview(alarmLabel)
        containerView.addSubview(vibrationLabel)
        containerView.addSubview(alarmNameTextField)
        containerView.addSubview(vibrationToggle)
        containerView.addSubview(openedButton)
        view.addSubview(missionSubLabel)
        view.addSubview(missionSettingLabel)
        view.addSubview(addMissionButton)
        addMissionButton.addSubview(circleView)
        addMissionButton.addSubview(missionTextLabel)
        circleView.addSubview(missionImageLabel)
        
        setupConstraints()
        setupWeekdayButtons()
    }
    
    private func setupConstraints() {
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        timePicker.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(timePicker.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(20)
        }
        
        weekdayButtonsStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }
        
        alarmLabel.snp.makeConstraints {
            $0.top.equalTo(weekdayButtonsStackView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        alarmNameTextField.snp.makeConstraints {
            $0.centerY.equalTo(alarmLabel.snp.centerY)
            $0.leading.equalTo(alarmLabel.snp.trailing).offset(10)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
        }
        
        vibrationLabel.snp.makeConstraints {
            $0.top.equalTo(alarmLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        vibrationToggle.snp.makeConstraints {
            $0.centerY.equalTo(vibrationLabel.snp.centerY)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
        }
        
        missionSettingLabel.snp.makeConstraints {
            $0.top.equalTo(vibrationLabel.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(20)
        }
        
        missionSubLabel.snp.makeConstraints {
            $0.top.equalTo(missionSettingLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        addMissionButton.snp.makeConstraints {
            $0.top.equalTo(missionSubLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(82)
        }
        
        circleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(60)
        }

        missionImageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        missionTextLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(circleView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
        }
        
        openedButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-50)
            $0.trailing.equalTo(containerView.snp.trailing).offset(-20)
            $0.height.equalTo(56)
        }
    }
    
    private func setupWeekdayButtons() {
        let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
        for (index, weekday) in weekdays.enumerated() {
            let button = UIButton()
            button.setTitle(weekday, for: .normal)
            button.backgroundColor = UIColor(named: "neutral050")
            button.setTitleColor(UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1), for: .normal)
            button.layer.cornerRadius = 17
            button.tag = index
            button.addTarget(self, action: #selector(weekdayButtonTapped(_:)), for: .touchUpInside)
            weekdayButtonsStackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalToConstant: 36).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            weekdayButtons.append(button)
        }
        weekdayButtonsStackView.spacing = 12
    }
    
    @objc private func weekdayButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? UIColor(named: "primary400") : UIColor(named: "neutral050")
        sender.setTitleColor(sender.isSelected ? .white : UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1), for: .normal)
    }
    
    private func setupBindings() {
        let viewModel = GroupJoinAlarmViewModel()
        
        let weekdaySelection = Observable.merge(
            weekdayButtons.map { button in
                button.rx.tap.map { _ in
                    self.weekdayButtons.map { $0.isSelected }
                }
            }
        ).startWith(weekdayButtons.map { $0.isSelected })

        let input = GroupJoinAlarmViewModel.Input(
            alarmName: alarmNameTextField.rx.text.orEmpty.asObservable(),
            timeSelected: timePicker.rx.date.asObservable(),
            weekdaySelection: weekdaySelection,
            vibrationEnabled: vibrationToggle.rx.isOn.asObservable(),
            joinButtonTapped: openedButton.rx.tap.asObservable(),
            roomId: roomId,
            missionId: missionId,
            missionObjectId: missionObjectId ?? 1
        )
        
        let output = viewModel.transform(input: input)
        
        output.isJoinButtonEnabled
            .bind(to: openedButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.joinGroupResponse
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    if let navigationController = self?.navigationController {
                        navigationController.popViewController(animated: true)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            navigationController.dismiss(animated: true, completion: nil)
                        }
                    }
                case .failure(let error):
                    print("\(error.localizedDescription)")
                    if let navigationController = self?.navigationController {
                        navigationController.popViewController(animated: true)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            navigationController.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
