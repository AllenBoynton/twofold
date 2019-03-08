//
//  MemoryGame.swift
//  twofold
//
//  Created by Allen Boynton on 2/21/19.
//  Copyright © 2019 Allen Boynton. All rights reserved.
//

import Foundation
import UIKit.UIImage
import Darwin

class MemoryGame {
    
    // MARK: - Properties
    var cards: [Card] = [Card]()
    var delegate: GameDelegate?
    var isPlaying: Bool = false
    
    fileprivate var cardsShown: [Card] = [Card]()
    fileprivate var startTime: Date?
    
    // Gets number of cards
    var numberOfCards: Int {
        get {
            return cards.count
        }
    }
    
    // Calculates time passed
    var elapsedTime: TimeInterval {
        get {
            guard startTime != nil else {
                return -1
            }
            return Date().timeIntervalSince(startTime!)
        }
    }
    
    // MARK: - Methods
    
    // Operations to start off a new game
    func newGame(_ cardsData: [UIImage]) {
        cards = randomCards(cardsData)
        startTime = Date.init()
        isPlaying = true
        delegate?.memoryGameDidStart(self)
    }
    
    // Operations when game has been stopped
    func stopGame() {
        isPlaying = false
        cards.removeAll()
        cardsShown.removeAll()
        startTime = nil
    }
    
    // Function to determine shown unpaired and paired cards
    func didSelectCard(_ card: Card?) {
        guard let card = card else { return }
        
        delegate?.memoryGame(self, showCards: [card])
        
        // If cards are not a match
        if unpairedCardShown() {
            let unpaired = unpairedCard()!
            if card.equals(unpaired) {
                cardsShown.append(card)
            } else {
                let unpairedCard = cardsShown.removeLast()
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.delegate?.memoryGame(self, hideCards: [card, unpairedCard])
                }
            }
        } else {
            // If cards are a match
            cardsShown.append(card)
        }
        
        // Adjusts remaining cards. If none -> finish the game
        if cardsShown.count == cards.count {
            finishGame()
        }
    }
    
    // Helps assign cards and adjusts card index
    func cardAtIndex(_ index: Int) -> Card? {
        if cards.count > index {
            return cards[index]
        } else {
            return nil
        }
    }
    
    func indexForCard(_ card: Card) -> Int? {
        for index in 0...cards.count - 1 {
            if card === cards[index] {
                return index
            }
        }
        return nil
    }
    
    // Determines if game is being played and if not...capture time
    fileprivate func finishGame() {
        // Game Over methods
        isPlaying = false
        delegate?.memoryGameDidEnd(self, elapsedTime: elapsedTime)
    }
    
    // Matches cards with same value using remainder
    fileprivate func unpairedCardShown() -> Bool {
        return cardsShown.count % 2 != 0
    }
    
    // Assigns card to be assigned with a match
    fileprivate func unpairedCard() -> Card? {
        let unpairedCard = cardsShown.last
        return unpairedCard
    }
    
    /*************************************** Random Images ***********/
    
    // Pick random cards for game board
    fileprivate func randomCards(_ cardsData:[UIImage]) -> [Card] {
        var cards = [Card]()
        if cardsData.count > 0 {
            for i in 0...cardsData.count - 1 {
                let card = Card.init(image: cardsData[i])
                cards.append(contentsOf: [card, Card.init(card: card)])
            }
        }
        return cards.shuffled()
    }
}

// Mark: - ************** Future gen?CardImages **************
extension MemoryGame {

    static var topCardImages: [UIImage] = [
        UIImage(named: "1")!
    ]
    
    static var gen1Images: [UIImage] = [
        UIImage(named: "test")!
    ]
    
    static var gen2Images: [UIImage] = [
        UIImage(named: "test")!
    ]
    
    static var gen3Images: [UIImage] = [
        UIImage(named: "test")!
    ]
    
    static var gen4Images: [UIImage] = [
        UIImage(named: "test")!
    ]
    
    static var gen5Images: [UIImage] = [
        
    ]
    
    static var gen6Images: [UIImage] = [
        
    ]
    
    static var gen7Images: [UIImage] = [
        
    ]
}
