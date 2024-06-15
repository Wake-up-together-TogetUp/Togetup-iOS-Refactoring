//
//  GroupCalendarViewController.swift
//  TogetUp
//
//  Created by nayeon  on 6/14/24.
//

import UIKit
import SnapKit
import FSCalendar

class GroupCalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
    }
    
    // MARK: - Properties
    private let previousMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendarLeft"), for: .normal)
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendarRight"), for: .normal)
        return button
    }()
    
    private let calendarView: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scope = .month
        calendar.headerHeight = 35
        calendar.appearance.headerDateFormat = "YYYY년 MM월"
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleAlignment = .left
        calendar.appearance.headerTitleOffset = CGPoint(x: -UIScreen.main.bounds.width / 5, y: 0)
        return calendar
    }()
    
    private let toggleCalendarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("접기/펴기", for: .normal)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 100, height: 100)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        return collectionView
    }()
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(calendarView)
        contentView.addSubview(toggleCalendarButton)
        contentView.addSubview(collectionView)
        
        calendarView.delegate = self
        calendarView.dataSource = self
        
        setupCustomHeader()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "secondary050")

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "그룹 캘린더"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingButtonTapped))
    }
    
    private func setupCustomHeader() {
        let headerView = calendarView.calendarHeaderView
        headerView.backgroundColor = UIColor(named: "secondary050")
        headerView.addSubview(previousMonthButton)
        headerView.addSubview(nextMonthButton)
        
        previousMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(headerView)
            $0.trailing.equalTo(nextMonthButton).offset(-40)
        }
        
        nextMonthButton.snp.makeConstraints {
            $0.centerY.equalTo(headerView)
            $0.trailing.equalTo(headerView).offset(-8)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview() // Content width matches scroll view width
        }
        
        setupCustomHeader()
        calendarView.snp.makeConstraints {
            $0.top.equalTo(contentView.safeAreaLayoutGuide).offset(5)
            $0.leading.trailing.equalToSuperview().inset(0)
            $0.height.equalTo(300)
        }
        
        toggleCalendarButton.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(toggleCalendarButton.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        toggleCalendarButton.addTarget(self, action: #selector(toggleCalendarScope), for: .touchUpInside)
        previousMonthButton.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
    }
    
    @objc private func toggleCalendarScope() {
        calendarView.setScope(calendarView.scope == .month ? .week : .month, animated: true)
    }
    
    @objc private func previousMonthTapped() {
        calendarView.setCurrentPage(calendarView.currentPage.previousMonth, animated: true)
    }
    
    @objc private func nextMonthTapped() {
        calendarView.setCurrentPage(calendarView.currentPage.nextMonth, animated: true)
    }
    
    @objc private func settingButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension GroupCalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    // MARK: - FSCalendarDelegate & DataSource
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    }
}

// MARK: - Date Extension
extension Date {
    var previousMonth: Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    
    var nextMonth: Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
}


#Preview {
    let navigationController = UINavigationController(rootViewController: GroupCalendarViewController())
    return navigationController
}
