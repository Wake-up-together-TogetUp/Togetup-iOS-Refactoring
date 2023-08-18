//
//  SceneDelegate.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import AuthenticationServices
import RxSwift
import KakaoSDKUser
import RxKakaoSDKUser
import KakaoSDKCommon

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let disposeBag = DisposeBag()
    var window: UIWindow?

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
          if let url = URLContexts.first?.url {
              if (AuthApi.isKakaoTalkLoginUrl(url)) {
                  _ = AuthController.rx.handleOpenUrl(url: url)
              }
          }
      }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: KeyChainManager.shared.getUserIdentifier()!) { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    DispatchQueue.main.async {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

                        self.window?.rootViewController = viewController
                        self.window?.makeKeyAndVisible()
                    }
                    
                case .revoked, .notFound:
                    DispatchQueue.main.async {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let loginNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

                        self.window?.rootViewController = loginNavigationController
                        self.window?.makeKeyAndVisible()
                    }

                default:
                    print(error?.localizedDescription)
                }
            }
        if (AuthApi.hasToken()) {
            UserApi.shared.rx.accessTokenInfo()
                .subscribe(onSuccess:{ (_) in
                    DispatchQueue.main.async {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

                        self.window?.rootViewController = viewController
                        self.window?.makeKeyAndVisible()
                    }
                }, onFailure: {error in
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        DispatchQueue.main.async {
                            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let loginNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

                            self.window?.rootViewController = loginNavigationController
                            self.window?.makeKeyAndVisible()
                        }
                    }
                    else {
                        print(error.localizedDescription)
                    }
                })
                .disposed(by: disposeBag)
        }
        else {
            DispatchQueue.main.async {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

                self.window?.rootViewController = loginNavigationController
                self.window?.makeKeyAndVisible()
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

