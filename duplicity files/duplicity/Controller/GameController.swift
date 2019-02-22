//
//  PokeMatchViewController.swift
//  duplicity
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import UIKit
import FirebasePerformance
import GoogleMobileAds

// Global Identifier
let cellID = "PokeCell"

class GameController: UIViewController {
    
    private var gameController = MemoryGame()
    private var optionsVC = OptionsViewController()
    
    // Collection view to hold all images
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Outlet for game display
    @IBOutlet weak var timerDisplay: UILabel!
    
    // Outlets for views
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var difficultyLabel: UILabel!
    
    // MARK - Local variables
    
    // AdMob banner ad
    private var adBannerView: GADBannerView!
    
    // Time passed to FinalScoreVC
    private var gameTimePassed = UILabel()
    
    // Deducts images until we reach 0 and the user wins
    private var gameOver = Bool()
    
    // NSTimers for game time and delays in revealed images
    private var timer: Timer?
    private var timer1 = Timer(), timer2 = Timer(), timer3 = Timer()
    
    // Time values instantiated
    private var startTime: Double = 0
    private var time: Double = 0
    private var seconds = 0.99
    private var elapsed: Double = 0
    private var display: String = ""
    private var isTimerRunning = false
    private var resumeTapped = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        collectionView.reloadData()
        resetGame()
        if musicIsOn {
            bgMusic?.play()
            musicIsOn = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleAdRequest()
        GADMobileAds.sharedInstance().applicationVolume = 0.5
        handleDifficultyLabel()
        gameController.delegate = self
        restartButton.isHidden = true
    }
    
    // Sets up for new game
    private func setupNewGame(numCards: UInt) {
        let cardsData: [UIImage] = imageGroupArray.sample(numCards) 
        gameController.newGame(cardsData)
    }
    
    // Created to reset game. Resets points, time and start button.
    private func resetGame() {
        gameController.stopGame()
        if timer?.isValid == true {
            timer?.invalidate()
        }
        
        bottomView.isHidden = true
        restartButton.isHidden = true
        collectionView.isHidden = true
        collectionView.isUserInteractionEnabled = true
        collectionView.reloadData()
        
        cancelButton.isHidden = false
        cancelButton.isEnabled = true
        
        playButton.isHidden = false
        playButton.isEnabled = true
    }
    
    private func handleDifficultyLabel() {
        switch defaults.integer(forKey: "difficulty") {
        case 0:
            difficultyLabel.text = "Difficulty: Easy"
        case 1:
            difficultyLabel.text = "Difficulty: Medium"
        case 2:
            difficultyLabel.text = "Difficulty: Hard"
        default:
            difficultyLabel.text = ""
        }
    }
}

// MARK: - MemoryGameDelegate

extension GameController: GameDelegate {
    func memoryGameDidStart(_ game: MemoryGame) {
        collectionView.reloadData()
        collectionView.isUserInteractionEnabled = true
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(startGameTimer), userInfo: nil, repeats: true)
    }
    
    // Function for cards that are being shown
    func memoryGame(_ game: MemoryGame, showCards cards: [Card]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! PokeViewCell
            cell.showCard(true, animated: true)
        }
    }
    
    // Function for cards that are being hidden
    func memoryGame(_ game: MemoryGame, hideCards cards: [Card]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! PokeViewCell
            cell.showCard(false, animated: true)
        }
    }
    
    // End of game methods
    func memoryGameDidEnd(_ game: MemoryGame, elapsedTime: TimeInterval) {
        timer?.invalidate()
                
        if musicIsOn {
            bgMusic?.pause()
            Music().playWinnerAudio1()
            
            let delay = DispatchTime.now() + 5.0
            DispatchQueue.main.asyncAfter(deadline: delay) {
                // Your code with delay
                bgMusic?.play()
                musicIsOn = true
            }
        } 
        
        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when) {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "HighScoreViewController") as! HighScoreViewController
            myVC.timePassed = self.display
            self.present(myVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension GameController: UICollectionViewDataSource {
    // Determines which device the user has - determines # of cards
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Device.IS_IPHONE {
            return gameController.numberOfCards > 0 ? gameController.numberOfCards: 20
        } else {
            return gameController.numberOfCards > 0 ? gameController.numberOfCards: 30
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PokeViewCell
        cell.showCard(false, animated: false)
        
        guard let card = gameController.cardAtIndex(indexPath.item) else { return cell }
        cell.card = card
        
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension GameController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PokeViewCell
        
        if cell.shown { return }
        gameController.didSelectCard(cell.card)
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GameController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var itemWidth: CGFloat!
        var itemHeight: CGFloat!
        
        if Device.IS_IPHONE {
            switch difficulty {
            case 6:
                itemWidth = collectionView.frame.width / 3 - 12.0
                itemHeight = collectionView.frame.height / 4 - 10.0
            case 8:
                itemWidth = collectionView.frame.width / 4 - 8.0
                itemHeight = collectionView.frame.height / 4 - 14.0
            case 10:
                itemWidth = collectionView.frame.width / 4 - 8.0
                itemHeight = collectionView.frame.height / 5 - 10.0
            default:
                itemWidth = collectionView.frame.width / 3 - 12.0
                itemHeight = collectionView.frame.height / 4 - 10.0
                break
            }
        } else if Device.IS_IPAD {
            switch iPadDifficulty {
            case 6:
                itemWidth = collectionView.frame.width / 3 - 12.0
                itemHeight = collectionView.frame.height / 4 - 10.0
            case 10:
                itemWidth = collectionView.frame.width / 4 - 8.0
                itemHeight = collectionView.frame.height / 5 - 12.0
            case 15:
                itemWidth = collectionView.frame.width / 5 - 8.0
                itemHeight = collectionView.frame.height / 6 - 10.0
            default:
                itemWidth = collectionView.frame.width / 4 - 12.0
                itemHeight = collectionView.frame.height / 5 - 10.0
                break
            }
        }
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    // MARK - IBAction functions
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        // Begin with new setup
        if Device.IS_IPHONE {
            setupNewGame(numCards: difficulty)
        } else {
            setupNewGame(numCards: iPadDifficulty)
        }
        // Shows button at beginning of game
        restartButton.isHidden = false
        playButton.isHidden = true
        playButton.isEnabled = false
        cancelButton.isHidden = true
        cancelButton.isEnabled = false
        
        // Unhides views after start button is pressed
        collectionView.isHidden = false
        bottomView.isHidden = false
    }
    
    // Back button to bring to main menu
    @IBAction func backButtonTapped(_ sender: Any) {
        timer?.invalidate()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OptionsViewController")
        self.show(vc!, sender: self)
    }
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        timer?.invalidate()
        resetGame()
        
        // Shows button at beginning of game
        playButton.isHidden = false
        playButton.isEnabled = true
        
        // Unhides views after start button is pressed
        collectionView.isHidden = true
        bottomView.isHidden = true
    }
    
    func timeString() -> String {
        time = gameController.elapsedTime
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        let milli = Int(time * 100)
        return String(format:"%02d:%02d:%02d", minutes, seconds, milli)
    }
    
    // Updates game time on displays
    @objc func startGameTimer() -> String {
        // Calculate total time since timer started in seconds
        time = gameController.elapsedTime
        
        // Calculate minutes
        let minutes = UInt32(time / 60.0)
        time -= (TimeInterval(minutes) * 60)
        
        // Calculate seconds
        let seconds = UInt32(time)
        time -= TimeInterval(seconds)
        
        // Calculate milliseconds
        let milliseconds = UInt32(time * 100)
        
        // Format time vars with leading zero
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strMilliseconds = String(format: "%02d", milliseconds)
        
        // Add time vars to relevant labels
        display = String(format: "\(strMinutes):\(strSeconds).\(strMilliseconds)", NSLocalizedString("", comment: ""), gameController.elapsedTime)
        
        // Display game time counter
        timerDisplay.text = display
        
        return display
    }
}

extension GameController: GADBannerViewDelegate {
    // MARK: - view positioning
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
    
    // MARK:  AdMob banner ad
    func handleAdRequest() {
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(adBannerView)
        
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-2292175261120907/6252355617"
        adBannerView.rootViewController = self
        adBannerView.delegate = self
        
        adBannerView.load(request)
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.debugDescription)
    }
}
