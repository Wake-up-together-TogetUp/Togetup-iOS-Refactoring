//
//  GroupCalendarViewController.swift
//  TogetUp
//
//  Created by nayeon  on 6/14/24.
//

import UIKit
import SnapKit
import FSCalendar
import RxSwift

class GroupCalendarViewController: UIViewController {
    
    private let viewModel: GroupCalendarViewModel
    private let disposeBag = DisposeBag()
    private let dateSelectedSubject = PublishSubject<Date>()
    var selectedRoomId: Int = 0
    
    init(roomId: Int) {
        self.viewModel = GroupCalendarViewModel(roomId: roomId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Properties
    private let previousMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendarLeft"), for: .normal)
        button.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendarRight"), for: .normal)
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private let headerSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private var rightCharacter: UIImageView = {
        let img = UIImageView(image: UIImage(named: "itemR_SENIOR_CHICK"))
        return img
    }()
    
    private let leftCharacter: UIImageView = {
        let img = UIImageView(image: UIImage(named: "itemL_SENIOR_CHICK"))
        return img
    }()
    
    private let centerCharacter: UIImageView = {
        let img = UIImageView(image: UIImage(named: "C_SENIOR_CHICK"))
        return img
    }()
    
    private let calendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scope = .week
        calendar.headerHeight = 52
        calendar.appearance.headerDateFormat = "YYYY년 MM월 W주차"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.weekdayTextColor = UIColor(named: "neutral300")
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.todayColor = UIColor(named: "neutral800")
        calendar.appearance.selectionColor = UIColor(named: "primary100")
        calendar.appearance.headerTitleAlignment = .left
        calendar.appearance.headerTitleOffset = CGPoint(x: -UIScreen.main.bounds.width / 5, y: 0)
        calendar.backgroundColor = .white
        return calendar
    }()
    
    private let toggleCalendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setImage(UIImage(named: "chevron-down"), for: .normal)
        button.tintColor = UIColor(named: "neutral400")
        button.layer.cornerRadius = 20
        return button
    }()
    
    private var backGroundImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "bg_SENIOR_CHICK")
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let numberOfColumns: CGFloat = 2
        let itemWidth = (UIScreen.main.bounds.width - 20 * 2 - (numberOfColumns - 1) * layout.minimumInteritemSpacing) / numberOfColumns
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private func setupUI() {
        view.addSubview(backGroundImage)
        view.addSubview(headerSeparatorView)
        view.addSubview(collectionView)
        view.addSubview(rightCharacter)
        view.addSubview(calendarView)
        view.addSubview(toggleCalendarButton)
        view.addSubview(leftCharacter)
        view.addSubview(centerCharacter)
        view.addSubview(previousMonthButton)
        view.addSubview(nextMonthButton)
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        setupCustomHeader()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "secondary050")
        appearance.shadowColor = .clear
        
        appearance.titleTextAttributes = [
            .font: UIFont(name: "AppleSDGothicNeo-Bold", size: 18),
            .foregroundColor: UIColor.black
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingButtonTapped))
    }
    
    private func setupCustomHeader() {
        let headerView = calendarView.calendarHeaderView
        headerView.backgroundColor = UIColor(named: "secondary050")
        
        previousMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(headerView)
            $0.trailing.equalTo(nextMonthButton).offset(-40)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(headerView)
            $0.trailing.equalTo(headerView).offset(-8)
        }
        
        headerSeparatorView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
    }
    
    private func setupConstraints() {
        setupCustomHeader()
        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.leading.trailing.equalToSuperview().inset(0)
            $0.height.equalTo(300)
        }
        
        toggleCalendarButton.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(-10)
            $0.leading.trailing.equalToSuperview().offset(0)
            $0.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(toggleCalendarButton.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(0)
        }
        
        backGroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        leftCharacter.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(104)
            $0.left.equalTo(view.snp.left)
            $0.centerY.equalTo(view.snp.centerY).offset(104)
        }
        
        rightCharacter.snp.makeConstraints {
            $0.width.equalTo(52)
            $0.height.equalTo(104)
            $0.right.equalTo(view.snp.right)
            $0.centerY.equalTo(view.snp.centerY).offset(-104)
        }
        
        centerCharacter.snp.makeConstraints {
            $0.width.equalTo(153)
            $0.height.equalTo(160)
            $0.centerX.equalTo(view.snp.centerX)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(0)
        }
    }
    
    private func setupBindings() {
         let input = GroupCalendarViewModel.Input(
             viewWillAppear: rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { _ in },
             dateSelected: dateSelectedSubject.asObservable()
         )
         
         let output = viewModel.transform(input: input)
         
         output.selectedDateImages
             .drive(onNext: { [weak self] userLogs in
                 self?.collectionView.reloadData()
             })
             .disposed(by: disposeBag)
        
        output.groupName
            .drive(onNext: { [weak self] groupName in
                self?.navigationItem.title = groupName
            })
            .disposed(by: disposeBag)
        
        output.theme
            .drive(onNext: { [weak self] theme in
                self?.backGroundImage.image = UIImage(named: "bg_\(theme)")
                self?.leftCharacter.image = UIImage(named: "itemL_\(theme)")
                self?.rightCharacter.image = UIImage(named: "itemR_\(theme)")
                self?.centerCharacter.image = UIImage(named: "C_\(theme)")
            })
            .disposed(by: disposeBag)
        
        
        toggleCalendarButton.addTarget(self, action: #selector(toggleCalendarScope), for: .touchUpInside)
    }
    
    @objc private func toggleCalendarScope() {
      if self.calendarView.scope == .month {
        self.calendarView.setScope(.week, animated: true)
          self.calendarView.appearance.headerDateFormat = "YYYY년 MM월 W주차"
            toggleCalendarButton.setImage(UIImage(named: "chevron-down"), for: .normal)
        
      } else {
        self.calendarView.setScope(.month, animated: true)
        self.calendarView.appearance.headerDateFormat = "YYYY년 MM월"
          toggleCalendarButton.setImage(UIImage(named: "cheveron-up"), for: .normal)
      }
    }
    
    @objc private func previousMonthTapped() {
        if calendarView.scope == .week {
            let previousWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: calendarView.currentPage)
            calendarView.setCurrentPage(previousWeek!, animated: true)
        } else {
            let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendarView.currentPage)
            calendarView.setCurrentPage(previousMonth!, animated: true)
        }
    }

    @objc private func nextMonthTapped() {
        if calendarView.scope == .week {
            let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: calendarView.currentPage)
            calendarView.setCurrentPage(nextWeek!, animated: true)
        } else {
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendarView.currentPage)
            calendarView.setCurrentPage(nextMonth!, animated: true)
        }
    }

    
    @objc private func settingButtonTapped() {
        let settinglVC = GroupSettingsViewController(roomId:selectedRoomId)
        navigationController?.pushViewController(settinglVC, animated: true)
    }
}
// MARK: - extension
extension GroupCalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        dateSelectedSubject.onNext(date)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date <= Date()
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return date > Date() ? UIColor(named: "neutral200") : nil
    }
}

extension GroupCalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
}

extension GroupCalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedDateImagesRelay.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell 
        else { return UICollectionViewCell() }
        let userLog = viewModel.selectedDateImagesRelay.value[indexPath.item]
        let imageUrl = userLog.userCompleteType == "SUCCESS" ? userLog.missionPicLink : ""
        cell.configure(with: imageUrl, text: userLog.userName)
        return cell
    }
}

extension GroupCalendarViewController: UICollectionViewDelegate {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
      calendarView.snp.updateConstraints {
        $0.height.equalTo(bounds.height)
      }
      self.view.layoutIfNeeded()
     }
}

extension GroupCalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}
