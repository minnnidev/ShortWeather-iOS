//
//  WeekWeatherView.swift
//  ShortWeather
//
//  Created by KJ on 2023/01/09.
//

import UIKit

import SnapKit
import Then

final class WeekWeatherView: UIView {
    
    // MARK: - UI Components
    
    private let weekDescriptionView: UIView = UIView()
    private let dailyForecastLabel: UILabel = UILabel()
    private let timeZoneLabel: UILabel = UILabel()
    private let temperatureLabel: UILabel = UILabel()
    private let weekWeatherCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var weatherWeekModel: [WeatherWeekModel] = WeatherWeekModel.weatherWeekdummyData()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WeekWeatherView {
    
    // MARK: - UI Components Property
    
    private func setUI() {
        weekDescriptionView.do {
            $0.backgroundColor = .white
        }
        
        dailyForecastLabel.do {
            $0.text = "일별예보"
            $0.font = .fontGuide(.caption1)
            $0.textColor = Color.gray7
        }
        
        timeZoneLabel.do {
            $0.text = "오전 / 오후"
            $0.font = .fontGuide(.caption1)
            $0.textColor = Color.gray7
        }
        
        temperatureLabel.do {
            $0.text = "최저 / 최고"
            $0.font = .fontGuide(.caption1)
            $0.textColor = Color.gray7
        }
        
        weekWeatherCollectionView.do {
            $0.registerCell(WeekWeatherCollectionViewCell.self)
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .clear
        }
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        weekDescriptionView.addSubviews(dailyForecastLabel, timeZoneLabel, temperatureLabel)
        addSubviews(weekWeatherCollectionView, weekDescriptionView)
        
        weekDescriptionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().inset(34)
            $0.height.equalTo(38)
        }
        
        dailyForecastLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview()
        }
        
        timeZoneLabel.snp.makeConstraints {
            $0.top.equalTo(dailyForecastLabel)
            $0.centerX.equalToSuperview()
        }
        
        temperatureLabel.snp.makeConstraints {
            $0.top.equalTo(dailyForecastLabel)
            $0.trailing.equalToSuperview()
        }
        
        weekWeatherCollectionView.snp.makeConstraints {
            $0.top.equalTo(weekDescriptionView.snp.bottom)
            $0.leading.equalToSuperview().offset(28)
            $0.trailing.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Methods
    
    private func setDelegate() {
        weekWeatherCollectionView.delegate = self
        weekWeatherCollectionView.dataSource = self
    }
}

//MARK: - UICollectionViewDataSource

extension WeekWeatherView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherWeekModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: WeekWeatherCollectionViewCell.self, indexPath: indexPath)
        cell.setDataBind(model: weatherWeekModel[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension WeekWeatherView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = bounds.size.width - 56
        return CGSize(width: width, height: 72)
    }
}
