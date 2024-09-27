//
//  ImageCollectionViewCell.swift
//  TogetUp
//
//  Created by nayeon  on 6/14/24.
//

import UIKit

import UIKit
import SnapKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.addSubview(roundedView)
        roundedView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(30)
            $0.width.equalTo(81)
        }
        
        roundedView.addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }
    }
    
    func configure(with imageUrl: String, text: String) {
        textLabel.text = text
        roundedView.snp.updateConstraints {
            $0.width.equalTo(textLabel.intrinsicContentSize.width + 24)
            if let url = URL(string: imageUrl) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(named: "missionDefault")
                        }
                    }
                }.resume()
            } else {
                self.imageView.image = UIImage(named: "missionDefault")
            }
        }
    }
}
