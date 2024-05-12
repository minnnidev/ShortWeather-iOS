//
//  SplashViewController.swift
//  ShortWeather
//
//  Created by Mac Book Pro on 2023/01/01.
//

import UIKit

import Lottie
import Moya
import SnapKit
import Then

final class SplashViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let splashImageView: LottieAnimationView = LottieAnimationView(name: "splash")
    
    // MARK: - Properties

    private let defaults = UserDefaults.standard
    private let userProvider = MoyaProvider<UserService>(plugins:[NetworkLoggerPlugin()])
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setLayout()
    }
}

extension SplashViewController {
    
    // MARK: - UI Components Property
    
    private func setUI() {
        view.backgroundColor = .white
        view.addSubview(splashImageView)
        
        splashImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.play { [weak self] _ in
                self?.isExistUserInform()
            }
        }
    }
    
    // MARK: - Layout Helper
    
    private func setLayout() {
        splashImageView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
            $0.width.equalTo(CGFloat(120).adjusted)
        }
    }
    
    // MARK: - Network
    
    private func isExistUserInform() {
//        guard let deviceToken = defaults.string(forKey: DataKey.deviceToken) else {
//            UIViewController.modifyRootViewController(FirstInfoViewController())
//            return
//        }
//        APIConstants.deviceToken = deviceToken
//        userProvider.request(.checkUser) { response in
//            switch response {
//            case .success(let result):
//                do {
//                    guard let data = try result.map(GeneralResponse<CheckUserResponse>.self).data else {
//                        UIViewController.modifyRootViewController(FirstInfoViewController())
//                        return
//                    }
//                    APIConstants.jwtToken = data.accessToken
//                    UIViewController.modifyRootViewController(TodayWeatherViewController())
//                } catch(let error){
//                    print(error.localizedDescription)
//                    self.splashImageView.loopMode = .loop
//                }
//            case .failure(let error):
//                self.splashImageView.loopMode = .loop
//                print(error.localizedDescription)
//            }
//        }
        UIViewController.modifyRootViewController(TodayWeatherViewController())
    }
}
