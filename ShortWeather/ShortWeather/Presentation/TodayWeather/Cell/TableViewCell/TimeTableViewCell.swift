//
//  TimeTableViewCell.swift
//  ShortWeather
//
//  Created by 김민 on 2023/01/03.
//

import UIKit

import Moya
import SnapKit
import Then

enum HourWeather {
    case weather
    case precipitation
}

final class TimeTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = UILabel()
    private let tempButton: UIButton = UIButton()
    private let rainButton: UIButton = UIButton()
    private lazy var buttonStackView: UIStackView = UIStackView()
    private let hourCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Properties

    var hourWeatherState: HourWeather = .weather
    let detailProvider = MoyaProvider<TodayWeatherDetailService>(plugins: [NetworkLoggerPlugin(verbose: true)])
    var detailTempList: [DetailTemp] = []
    var detailRainList: [DetailRain] = []
    
    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
        setLayout()
        setAddTarget()
        setDelegate()
        fetchDetailTemp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TimeTableViewCell {
    
    // MARK: - UI Components property
    
    private func setUI() {
        contentView.backgroundColor = .white
        
        selectionStyle = .none
        
        tempButton.isSelected = true
        
        setHourButton(tempButton, rainButton)
        
        titleLabel.do {
            $0.text = Letter.hourWeather
            $0.font = .fontGuide(.subhead4)
        }
        
        hourCollectionView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.showsHorizontalScrollIndicator = false
            $0.registerCell(HourCollectionViewCell.self)
        }
        
        tempButton.do {
            $0.setTitle(Letter.weather, for: .normal)
        }
        
        rainButton.do {
            $0.setTitle(Letter.precipitation, for: .normal)
        }
        
        buttonStackView.do {
            $0.distribution = .fillEqually
            $0.spacing = 5
        }
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        contentView.addSubviews(titleLabel, buttonStackView, hourCollectionView)
        buttonStackView.addArrangedSubviews(tempButton, rainButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(32)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-30)
            $0.height.equalTo(36)
        }
        
        hourCollectionView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(25)
            $0.trailing.equalToSuperview().offset(-25)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
    
    // MARK: - Methods
    
    private func setAddTarget() {
        tempButton.addTarget(self, action: #selector(weatherButtonDidTap), for: .touchUpInside)
        rainButton.addTarget(self, action: #selector(precipitationButtonDidTap), for: .touchUpInside)
    }
    
    private func checkHourButton() {
        switch hourWeatherState {
        case .weather:
            tempButton.isSelected = true
            rainButton.isSelected = false
        case .precipitation:
            rainButton.isSelected = true
            tempButton.isSelected = false
        }
    }
    
    private func setDelegate() {
        hourCollectionView.delegate = self
        hourCollectionView.dataSource = self
    }
    
    private func setHourButton(_ buttons: UIButton...) {
        buttons.forEach {
            $0.titleLabel?.font = .fontGuide(.subhead3)
            $0.setTitleColor(Color.gray7, for: .normal)
            $0.setBackgroundColor(Color.gray0, for: .normal)
            $0.setTitleColor(Color.white, for: .selected)
            $0.setBackgroundColor(Color.pointColor, for: .selected)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 18
        }
    }
    
    // MARK: - @objc Methods
    
    @objc private func weatherButtonDidTap() {
        hourWeatherState = .weather
        hourCollectionView.reloadData()
        checkHourButton()
        fetchDetailTemp()
    }
    
    @objc private func precipitationButtonDidTap() {
        hourWeatherState = .precipitation
        hourCollectionView.reloadData()
        checkHourButton()
        fetchDetailRain()
    }
    
    // MARK: - Network
    
    private func fetchDetailTemp() {
        detailTempList.removeAll()
        detailProvider.request(.fetchDetailTemp) { response in
            switch response {
            case .success(let result):
                do {
                    let status = result.statusCode
                    if status >= 200 && status < 300 {
                        guard let data = try result.map(GeneralResponse<[DetailTempResponse]>.self).data else { return }
                        for dto in data {
                            self.detailTempList.append(dto.convertToDetailTemp())
                        }
                        self.hourCollectionView.reloadData()
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)

                let tempData = [
                    DetailTemp(date: "20230110", time: "0200", temperature: -2, day: false, image: "구름많음"),
                    DetailTemp(date: "20230110", time: "0300", temperature: -2, day: false, image: "흐림"),
                    DetailTemp(date: "20230110", time: "0400", temperature: -3, day: false, image: "맑음"),
                    DetailTemp(date: "20230110", time: "0500", temperature: -2, day: false, image: "맑음"),
                    DetailTemp(date: "20230110", time: "0600", temperature: -3, day: false, image: "맑음"),
                    DetailTemp(date: "20230110", time: "0700", temperature: -3, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "0800", temperature: -3, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "0900", temperature: -2, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1000", temperature: 0, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1100", temperature: 2, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1200", temperature: 4, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1300", temperature: 5, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1400", temperature: 6, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1500", temperature: 6, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1600", temperature: 6, day: true, image: "맑음"),
                    DetailTemp(date: "20230110", time: "1700", temperature: 6, day: true, image: "구름많음"),
                    DetailTemp(date: "20230110", time: "1800", temperature: 4, day: false, image: "구름많음"),
                    DetailTemp(date: "20230110", time: "1900", temperature: 3, day: false, image: "구름많음"),
                    DetailTemp(date: "20230110", time: "2000", temperature: 2, day: false, image: "구름많음"),
                    DetailTemp(date: "20230110", time: "2100", temperature: 1, day: false, image: "구름많음"),
                    DetailTemp(date: "20230110", time: "2200", temperature: 1, day: false, image: "흐림"),
                    DetailTemp(date: "20230110", time: "2300", temperature: 1, day: false, image: "구름많음"),
                    DetailTemp(date: "20230111", time: "0000", temperature: 0, day: false, image: "구름많음"),
                    DetailTemp(date: "20230111", time: "0100", temperature: 0, day: false, image: "구름많음")
                ]

                for data in tempData {
                    self.detailTempList.append(data)
                }
                self.hourCollectionView.reloadData()

            }
        }
    }
    
    private func fetchDetailRain() {
        detailRainList.removeAll()
        detailProvider.request(.fetchDetailRain) { response in
            switch response {
            case .success(let result):
                do {
                    let status = result.statusCode
                    if status >= 200 && status < 300 {
                        guard let data = try result.map(GeneralResponse<[DetailRainResponse]>.self).data else { return }
                        for dto in data {
                            self.detailRainList.append(dto.convertToDetailRain())
                        }
                        self.hourCollectionView.reloadData()
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)

                let rainData = [
                    DetailRain(date: "20230110", time: "0200", rain: 0),
                    DetailRain(date: "20230110", time: "0300", rain: 0),
                    DetailRain(date: "20230110", time: "0400", rain: 0),
                    DetailRain(date: "20230110", time: "0500", rain: 0),
                    DetailRain(date: "20230110", time: "0600", rain: 0),
                    DetailRain(date: "20230110", time: "0700", rain: 0),
                    DetailRain(date: "20230110", time: "0800", rain: 0),
                    DetailRain(date: "20230110", time: "0900", rain: 0),
                    DetailRain(date: "20230110", time: "1000", rain: 0),
                    DetailRain(date: "20230110", time: "1100", rain: 0),
                    DetailRain(date: "20230110", time: "1200", rain: 0),
                    DetailRain(date: "20230110", time: "1300", rain: 0),
                    DetailRain(date: "20230110", time: "1400", rain: 0),
                    DetailRain(date: "20230110", time: "1500", rain: 0),
                    DetailRain(date: "20230110", time: "1600", rain: 0),
                    DetailRain(date: "20230110", time: "1700", rain: 20),
                    DetailRain(date: "20230110", time: "1800", rain: 20),
                    DetailRain(date: "20230110", time: "1900", rain: 20),
                    DetailRain(date: "20230110", time: "2000", rain: 20),
                    DetailRain(date: "20230110", time: "2100", rain: 20),
                    DetailRain(date: "20230110", time: "2200", rain: 30),
                    DetailRain(date: "20230110", time: "2300", rain: 20),
                    DetailRain(date: "20230111", time: "0000", rain: 20),
                    DetailRain(date: "20230111", time: "0100", rain: 20)
                ]

                for data in rainData {
                    self.detailRainList.append(data)
                }
                self.hourCollectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TimeTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch hourWeatherState {
        case .weather:
            return detailTempList.count
        case .precipitation:
            return detailRainList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: HourCollectionViewCell.self, indexPath: indexPath)
        switch hourWeatherState {
        case .weather:
            cell.setWeatherDataBind(detailTempList[indexPath.row])
        case .precipitation:
            cell.setPrecipitationDataBind(detailRainList[indexPath.row])
        }
        if indexPath.row == 0 {
            cell.setCurrent()
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TimeTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 82)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}
