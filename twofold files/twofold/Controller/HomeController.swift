//
//  HomeController.swift
//  twofold
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit
import GameKit

class HomeController: UIViewController {
    
    // Class delegates
    var gameController = MemoryGame()
    var music = Music()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var startButton: DesignableButtons!
    @IBOutlet weak var musicButton: UIButton!
    
    let localPlayer = GKLocalPlayer.local
    
    private let shouldIncrement = true
    private var gcEnabled = Bool() // Check if the user has Game Center enabled
    private var gcDefaultLeaderBoard = String() // Check the default
    let GKPlayerAuthenticationDidChangeNotificationName: String = ""
    let score = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        theme = UInt(defaults.integer(forKey: "theme"))
        setupTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticatePlayer()
    }
    
    private func setupTheme() {
        switch theme {
        case 0:
            handleTheme(bgColor: StickmanTheme.stickmanBGColor, textColor: .black, btnBgColor: StickmanTheme.stickmanTintColor, image: "8")
        case 1:
            handleTheme(bgColor: ButterflyTheme.butterflyBGColor, textColor: ButterflyTheme.butterflyTintColor, btnBgColor: ButterflyTheme.butterflyTintColor, image: "30")
        case 2:
            handleTheme(bgColor: BeachTheme.beachBGColor, textColor: BeachTheme.beachTintColor, btnBgColor: BeachTheme.beachTintColor, image: "51")
        case 3:
            handleTheme(bgColor: JungleTheme.jungleBGColor, textColor: JungleTheme.jungleTintColor, btnBgColor: JungleTheme.jungleTextColor, image: "77")
        default:
            self.view.backgroundColor = .green
        }
        imageView2.image = imageView.image?.withHorizontallyFlippedOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    private func handleTheme(bgColor: UIColor, textColor: UIColor, btnBgColor: UIColor, image: String) {
        self.view.backgroundColor = bgColor
        imageView.image = UIImage(named: image)
        titleLabel.textColor = textColor
        subTitleLabel.textColor = textColor
        startButton.backgroundColor = btnBgColor
        musicButton.tintColor = textColor
    }
    
    // Authenticates the user to access to the GC
    func authenticatePlayer() {
        localPlayer.authenticateHandler = {(view, error) -> Void in
            if view != nil {
                
                // 1. Show login if player is not logged in
                self.present(view!, animated: true, completion: nil)
                
                NotificationCenter.default.addObserver(
                    self, selector: #selector(self.authenticationDidChange(_:)),
                    name: NSNotification.Name(rawValue: self.GKPlayerAuthenticationDidChangeNotificationName),
                    object: nil)
                
            } else if self.localPlayer.isAuthenticated {
                
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                self.localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier, error) in
                    if error != nil {
                        print(error as Any)
                    } else {
                        self.gcDefaultLeaderBoard = leaderboardIdentifier!
                    }
                })
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print(error.debugDescription)
            }
        }
    }
    
    // Report example score after user logs in
    @objc func authenticationDidChange(_ notification: Notification) {}
    
    // Authentication notification
    func notificationReceived() {
        print("GKPlayerAuthenticationDidChangeNotificationName - Authentication Status: \(localPlayer.isAuthenticated)")
    }
    
    // Music button to turn music on/off
    @IBAction func muteButtonTapped(_ sender: UIButton) {
        music.handleMuteMusic(clip: bgMusic)
        if musicIsOn {
            let origImage = UIImage(named: "audio")
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            musicButton.setImage(tintedImage, for: .normal)
            musicIsOn = true
        } else {
            let origImage = UIImage(named: "mute3")
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            musicButton.setImage(tintedImage, for: .normal)
            musicIsOn = false
        }
    }
}

