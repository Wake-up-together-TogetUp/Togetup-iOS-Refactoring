//
//  TimelineCollectionViewCell.swift
//  TogetUp
//
//  Created by 이예원 on 11/26/23.
//

import UIKit

class TimelineCollectionViewCell: UICollectionViewCell {
    static let identifier = "TimelineCollectionViewCell"
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alarmInfoLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.cornerRadius = 8
        self.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = .clear
    }
    
    func setAttributes(with model: AlarmModel) {
        iconLabel.text = model.icon
        let timeText = model.alarmTime.toFormattedDateString(from: "HH:mm:ss", to: "a h:mm")
        
        timeLabel.text = timeText
        alarmInfoLabel.text = "\(model.name) | \(model.missionObject ?? "직접 촬영 미션")"
        
        adjustIconLabelAlphaBasedOnTime(model.alarmTime)
    }
    
    private func adjustIconLabelAlphaBasedOnTime(_ alarmTime: String) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US")
        
        let currentTimeString = inputFormatter.string(from: Date())
        if let alarmDate = inputFormatter.date(from: alarmTime), let currentDate = inputFormatter.date(from: currentTimeString) {
            let alphaValue: CGFloat = alarmDate < currentDate ? 0.4 : 1.0
            
            iconLabel.alpha = alphaValue
            timeLabel.alpha = alphaValue
            alarmInfoLabel.alpha = alphaValue
        }
    }
}
