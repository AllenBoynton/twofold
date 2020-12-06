//
//  HighScoreViewController.swift
//  twofold
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit
import GameKit
import GoogleMobileAds

// Global GC identifiers
let easyID = "EasyLeaderboard" // Easy Time Leaderboard
let mediumID = "MediumLeaderboard" // Medium Time Leaderboard
let hardID = "HardLeaderboard" // Hard Time Leaderboard

class HighScoreViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var newGameTimeStackview: UIStackView!
    @IBOutlet weak var bestEasyTimeStackView: UIStackView!
    @IBOutlet weak var bestMedTimeStackView: UIStackView!
    @IBOutlet weak var bestHardTimeStackView: UIStackView!
    @IBOutlet weak var bestTimesStackView: UIStackView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var easyHighScoreLbl: UILabel!
    @IBOutlet weak var mediumHighScoreLbl: UILabel!
    @IBOutlet weak var hardHighScoreLbl: UILabel!
    @IBOutlet weak var newHighScoreLabel: UILabel!
    
    @IBOutlet weak var bestTimeStackLabel: UILabel!
    
    @IBOutlet weak var gcIconView: UIView!
    
    @IBOutlet var headerLabels: [UILabel]!
    @IBOutlet var labels: [UILabel]!
    
    private var adBannerView: GADBannerView!
    private var interstitial: GADInterstitial!
    private var request = GADRequest()
    
    private var scoreReporter = GKScore()
    private var timeScore = Int()
    private var easyHighScore = Int()
    private var mediumHighScore = Int()
    private var hardHighScore = Int()
    private var numOfGames = 0
    
    private var minutes = Int()
    private var seconds = Int()
    private var millis = Int()
    
    var timePassed: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateGCIcon()
        loadImage()
        newHighScoreLabel.startBlink()
        addScore()
        setupLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interstitial = createAndLoadInterstitial()
        handleAdRequest()
        showItems()
        checkHighScoreForNil()
        numOfGames = defaults.integer(forKey: "Games")
        print("NumOfGames: \(numOfGames)")
        showTime()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.image = nil
    }
    
    private func setupLayout() {
        switch theme {
        case 0:
            handleTheme(bgColor: StickmanTheme.stickmanBGColor, navColor: StickmanTheme.stickmanBGColor, scoreColor: .blue, headerColor: .black, textColor: .darkGray, image: "\(Int.random(in: 1..<21))")
        case 1:
            handleTheme(bgColor: ButterflyTheme.butterflyBGColor, navColor: ButterflyTheme.butterflyTintColor, scoreColor: ButterflyTheme.butterflyTintColor, headerColor: .black, textColor: ButterflyTheme.butterflySegForegroundColorNormal, image: "\(Int.random(in: 21..<38))")
        case 2:
            handleTheme(bgColor: BeachTheme.beachBGColor, navColor: BeachTheme.beachTintColor, scoreColor: .red, headerColor: .blue, textColor: .white, image: "\(Int.random(in: 41..<58))")
        case 3:
            handleTheme(bgColor: JungleTheme.jungleBGColor, navColor: JungleTheme.jungleTintColor, scoreColor: JungleTheme.jungleBorderColor, headerColor: JungleTheme.jungleSegForegroundColorSelected, textColor: JungleTheme.jungleTextColor, image: "\(Int.random(in: 75..<79))")
        case 4:
            handleTheme(bgColor: SeaTheme.seaBGColor, navColor: SeaTheme.seaBorderColor, scoreColor: .red, headerColor: .blue, textColor: .white, image: "\(Int.random(in: 80..<97))")
        default:
            self.view.backgroundColor = .white
        }
    }
    
    private func handleTheme(bgColor: UIColor, navColor: UIColor, scoreColor: UIColor, headerColor: UIColor, textColor: UIColor, image: String) {
        self.view.backgroundColor = bgColor
        navigationController?.navigationBar.barTintColor = navColor
        newHighScoreLabel.textColor = scoreColor
        for label in headerLabels {
            label.textColor = headerColor
        }
        for label in labels {
            label.textColor = textColor
        }
        imageView.image = UIImage(named: image)
    }
    
    private func showTime() {
        if timePassed != nil {
            let numTime = convertStringToNumbers(time: timePassed!)!
            saveHighScore(numTime)
            if numTime <= 3000 {
                numOfGames += 1
                defaults.set(numOfGames, forKey: "Games")
            }
        } 
    }
    
    // Shows items depending on best score screen or final score screen
    private func showItems() {
        bestTimeStackLabel.isHidden = false
    }
    
    private func loadImage() {
        imageView.contentMode = .scaleAspectFit
    }
    
    /*************************** High Score Logic *********************/
    
    // Verifies score/time is not nil
    func checkHighScoreForNil() {
        if defaults.value(forKey: "EasyHighScore") != nil {
            easyHighScore = timeScore
            easyHighScore = defaults.value(forKey: "EasyHighScore") as! NSInteger
            easyHighScoreLbl.text = "\(intToScoreString(score: easyHighScore))"
        }
        if defaults.value(forKey: "MediumHighScore") != nil {
            mediumHighScore = timeScore
            mediumHighScore = defaults.value(forKey: "MediumHighScore") as! NSInteger
            mediumHighScoreLbl.text = "\(intToScoreString(score: mediumHighScore))"
        }
        if defaults.value(forKey: "HardHighScore") != nil {
            hardHighScore = timeScore
            hardHighScore = defaults.value(forKey: "HardHighScore") as! NSInteger
            hardHighScoreLbl.text = "\(intToScoreString(score: hardHighScore))"
        }
    }
    
    // Score format for time
    func intToScoreString(score: Int) -> String {
        minutes = score / 10000
        seconds = (score / 100) % 100
        millis = score % 100
        
        let scoreString = NSString(format: "%02i:%02i.%02i", minutes, seconds, millis) as String
        return scoreString
    }
    
    // Adds time from game to high scores. Compares against others for order
    func addScore() {
        if timePassed != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Options", style: .done, target: self, action: #selector(returnToOptionsVC))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play Again", style: .done, target: self, action: #selector(playAgainButtonPressed))
            navigationItem.title = "YOU WON!"
            timeScore = Int(convertStringToNumbers(time: timePassed!)!)
            timeLabel.text = "\(intToScoreString(score: timeScore))"
            
            if defaults.integer(forKey: "difficulty") == 0 {
                if (timeScore < easyHighScore) || (easyHighScore == 0) {
                    newHighScoreLabel.isHidden = false
                    bestEasyTimeStackView.startBlink()
                    easyHighScore = timeScore
                    defaults.set(easyHighScore, forKey: "EasyHighScore")
                    easyHighScoreLbl.text = "\(intToScoreString(score: Int(easyHighScore)))"
                }
            }
            
            if defaults.integer(forKey: "difficulty") == 1 {
                if (timeScore < mediumHighScore) || (mediumHighScore == 0) { // Change value for testing purposes
                    newHighScoreLabel.isHidden = false
                    bestMedTimeStackView.startBlink()
                    mediumHighScore = timeScore
                    defaults.set(mediumHighScore, forKey: "MediumHighScore")
                    mediumHighScoreLbl.text = "\(intToScoreString(score: Int(mediumHighScore)))"
                }
            }
            
            if defaults.integer(forKey: "difficulty") == 2 {
                if (timeScore < hardHighScore) || (hardHighScore == 0) { // Change value for testing purposes
                    newHighScoreLabel.isHidden = false
                    bestHardTimeStackView.startBlink()
                    hardHighScore = timeScore
                    defaults.set(hardHighScore, forKey: "HardHighScore")
                    hardHighScoreLbl.text = "\(intToScoreString(score: Int(hardHighScore)))"
                }
            }
        } else {
            self.title = "Best Times"
            bestTimeStackLabel.isHidden = true
            newGameTimeStackview.isHidden = true
            timeLabel.isHidden = true
        }
    }
    
    // Seperate string out to numbers
    func convertStringToNumbers(time: String) -> Int? {
        let strToInt = time.westernArabicNumeralsOnly
        return Int(strToInt)!
    }
    
    /*************************** GC Animation **********************/
    
    // Animate GC image
    private func animateGCIcon() {
        UIView.animate(withDuration: 1.5, animations: {
            self.gcIconView.transform = CGAffineTransform(scaleX: 20, y: 20)
            self.gcIconView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }) { (finished) in
            UIView.animate(withDuration: 0.8, animations: {
                self.gcIconView.transform = CGAffineTransform.identity
            })
        }
    }
    
    /**************************** IBActions ************************/
    
    // Play again game button to main menu
    @objc func playAgainButtonPressed(_ sender: Any) {
        // Return to game screen
        
        // Interstitial Ad setup
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func returnToOptionsVC(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OptionsViewHostingController")
        show(vc!, sender: self)
    }
    
    @IBAction func showGameCenter(_ sender: UIButton) {
        showLeaderboard()
        imageView.image = nil
    }
}
    
// MARK:  Game Center
extension HighScoreViewController: GKGameCenterControllerDelegate {
    
    /**************************** Game Center ***********************/
    
    private func saveHighScore(_ score: Int) {
        if GKLocalPlayer.local.isAuthenticated {
            // Save game time to GC
            if defaults.integer(forKey: "difficulty") == 0 {
                handleScoreReporter(id: easyID)
            }
            
            if defaults.integer(forKey: "difficulty") == 1 {
                handleScoreReporter(id: mediumID)
            }
            
            if defaults.integer(forKey: "difficulty") == 2 {
                handleScoreReporter(id: hardID)
            }
        }
    }
    
    private func handleScoreReporter(id: String) {
        scoreReporter = GKScore(leaderboardIdentifier: id)
        scoreReporter.value = Int64(timeScore)
        let gkScoreArray: [GKScore] = [scoreReporter]
        GKScore.report(gkScoreArray, withCompletionHandler: { error in
            guard error == nil else { return }
        })
    }
    
    // Retrieves the GC VC leaderboard
    func showLeaderboard() {
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .leaderboards
        
        // Show leaderboard
        self.present(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK:  AdMob
extension HighScoreViewController: GADBannerViewDelegate, GADInterstitialDelegate {
    /*************************** AdMob Requests ***********************/
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
    }
    
    // MARK: - view positioning
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide.bottomAnchor,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 0))
    }
    
    // Ad request
    func handleAdRequest() {
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(adBannerView)
        
        // Ad setup
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//ca-app-pub-2292175261120907/9576260829"
        adBannerView.rootViewController = self
        adBannerView.delegate = self
        adBannerView.load(request)
    }
    
    // Create and load an Interstitial Ad
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")//ca-app-pub-2292175261120907/1071084845")
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()        
        self.dismiss(animated: true, completion: nil)
    }
    
    // Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        if musicIsOn {
            bgMusic?.pause()
            musicIsOn = true
        } else {
            musicIsOn = false
        }
    }
    
    // Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if musicIsOn {
            bgMusic?.play()
        } else {
            bgMusic?.pause()
            musicIsOn = false
        }
    }
}
