//
//  ReviewViewController.swift
//  FoodPin_UIKit
//
//  Created by Андрей Бородкин on 22.03.2022.
//

import UIKit

class ReviewViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var rateButtons: [UIButton]!
    @IBOutlet var closeButton: UIButton!
    
    var restaurant = Restaurant()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.image = UIImage(named: restaurant.image)
        
        // Applying the blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        let moveDownTransform = CGAffineTransform.init(translationX: 0, y: -50)
        
        // Make the buttons invisible
        rateButtons.forEach {$0.alpha = 0; $0.transform = moveScaleTransform}
        closeButton.alpha = 0; closeButton.transform = moveDownTransform
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var delay: Double = 0.5
        rateButtons.forEach { rateButton in
            UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: []) {
                rateButton.alpha = 1
                rateButton.transform = .identity
                delay += 0.05
            }
        }
        
        UIView.animate(withDuration: 0.8, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: []) {
            self.closeButton.alpha = 1
            self.closeButton.transform = .identity
        }
           // self.rateButtons.forEach {$0.alpha = 1.0}
            
//            for button in self.rateButtons {
//                button.alpha = 1.0
//            }
        
        
    }

}
