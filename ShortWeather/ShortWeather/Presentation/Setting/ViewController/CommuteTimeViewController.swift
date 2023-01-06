//
//  CommuteSettingViewController.swift
//  ShortWeather
//
//  Created by 김민 on 2023/01/06.
//

import UIKit

import SnapKit
import Then

final class CommuteTimeViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = UILabel()
    private let selectCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private let checkButton: UIButton = UIButton()
    
    // MARK: - Properties
    
    var goingOutTime: String?
    var goingHomeTime: String?
    
    let info: [String] = ["외출시간", "귀가시간"]
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
        setDelegate()
    }
}

extension CommuteTimeViewController {
    
    // MARK: - UI Components Property
    
    private func setUI() {
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Image.icnExpandLeft,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonDidTap))
        navigationItem.leftBarButtonItem?.tintColor = Color.black
        navigationItem.title = "외출 / 귀가시간대 설정"
        
        titleLabel.do {
            $0.text = "시간대를 변경해주세요"
            $0.font = .fontGuide(.headline1)
        }
        
        selectCollectionView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.registerCells(SetSelectCollectionViewCell.self)
        }
        
        checkButton.do {
            $0.setTitle("확인", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.backgroundColor = Color.gray2
            $0.layer.cornerRadius = 15
        }
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        view.addSubviews(titleLabel, selectCollectionView, checkButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(29)
            $0.leading.equalToSuperview().offset(28)
        }
        
        selectCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.equalTo(titleLabel)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-34)
            $0.leading.equalTo(28)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(57)
        }
    }
    
    // MARK: - Methods
    
    private func popToSettingViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setDelegate() {
        selectCollectionView.delegate = self
        selectCollectionView.dataSource = self
    }
    
    // MARK: - @objc Methods
    
    @objc private func backButtonDidTap() {
        popToSettingViewController()
    }
    
    @objc private func halfModal(title: String ) {
        let vc = TimeViewController(titleText: title, listType: .goingHomeTime)
        vc.modalPresentationStyle = .pageSheet
        vc.delegate = self
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()] // 반만 고정
//            sheet.detents = [.medium(), .large()] // 반, 전체 다 자유롭게
            sheet.delegate = self
            sheet.prefersGrabberVisible = true
        }
        self.present(vc, animated: true, completion: nil);
    }
}

// MARK: - UICollectionViewDataSource

extension CommuteTimeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: SetSelectCollectionViewCell.self, indexPath: indexPath)

        cell.setDataBind(info: info[indexPath.row], pickData: "")
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CommuteTimeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 56
        return CGSize(width: width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(28)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            halfModal(title: "외출시간 설정")
        case 1:
            halfModal(title: "귀가시간 설정")
        default:
            halfModal(title: "외출시간 설정")
        }
    }
}

extension CommuteTimeViewController: UISheetPresentationControllerDelegate {
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}

extension CommuteTimeViewController: TimeViewControllerDelegate {
    
    func sendData(pickData: String, listType: SecondInfoType) {
        switch listType {
        case .goingOutTime:
            self.goingOutTime = pickData
        case .goingHomeTime:
            self.goingHomeTime = pickData
        default:
            break
        }
        selectCollectionView.reloadData()
    }
}
