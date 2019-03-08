//
//  GamecellCell.swift
//  twofold
//
//  Created by Allen Boynton on 11/23/18.
//  Copyright © 2018 Allen Boynton. All rights reserved.
//

import UIKit

class GameCell: UICollectionViewCell {
    // MARK: - Properties
    
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
        
    var card: Card? {
        didSet {
            guard let card = card else { return }
            frontImageView.image = card.image
        }
    }
    
    fileprivate(set) var shown: Bool = false
    
    // MARK: - Methods
    func showCard(_ show: Bool, animated: Bool) {
        
        frontImageView.isHidden = false
        self.frontImageView.layer.borderWidth = 2.0
        self.frontImageView.layer.borderColor = UIColor.blue.cgColor
        self.frontImageView.layer.cornerRadius = 8.0
        self.frontImageView.layer.masksToBounds = true
        
        backImageView.isHidden = false
        self.backImageView.layer.borderWidth = 2.0
        self.backImageView.layer.borderColor = UIColor.yellow.cgColor
        self.backImageView.layer.cornerRadius = 8.0
        self.backImageView.layer.masksToBounds = true
        
        shown = show
        
        if animated {
            if show {
                UIView.transition(from: backImageView,
                                  to: frontImageView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromLeft, .showHideTransitionViews],
                                  completion: { (finished: Bool) -> () in
                })
            } else {
                UIView.transition(from: frontImageView,
                                  to: backImageView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromRight, .showHideTransitionViews],
                                  completion:  { (finished: Bool) -> () in
                })
            }
        } else {
            if show {
                bringSubviewToFront(frontImageView)
                backImageView.isHidden = true
            } else {
                bringSubviewToFront(backImageView)
                frontImageView.isHidden = true
            }
        }
    }
}
