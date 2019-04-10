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
    
    @IBOutlet weak var imageView: UIImageView!
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        authenticatePlayer()
        theme = UInt(defaults.integer(forKey: "theme"))
        setupTheme()
    }
    
    private func setupTheme() {
        switch theme {
        case 0:
            self.view.backgroundColor = .white
            imageView.image = UIImage(named: "8")
        case 1:
            self.view.backgroundColor = UIColor.rgb(red: 247, green: 207, blue: 104)
            imageView.image = UIImage(named: "30")
        case 2:
            self.view.backgroundColor = UIColor.rgb(red: 70, green: 215, blue: 215)
            imageView.image = UIImage(named: "51")
        default:
            self.view.backgroundColor = .white
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    func handleMusicButtons() {
        let image = UIImage(named: "x")
        musicButton.setImage(image, for: .selected)
        if (bgMusic?.isPlaying)! {
            musicButton.alpha = 1.0
            musicButton.isSelected = false
            musicIsOn = true
        } else {
            musicButton.alpha = 0.4
            musicButton.isSelected = true
            musicIsOn = false
        }
    }
    
    // Music button to turn music on/off
    @IBAction func muteButtonTapped(_ sender: UIButton) {
        music.handleMuteMusic(clip: bgMusic)
        handleMusicButtons()
        if musicIsOn {
            musicButton.setImage(UIImage(named: "audio"), for: .normal)
            musicIsOn = true
        } else {
            musicButton.setImage(UIImage(named: "mute3"), for: .normal)
            musicIsOn = false
        }
    }
}

