//
//  AnimationViewController.swift
//  CoreDаta
//
//  Created by Roman Litvinovich on 25/10/2023.
//

import UIKit
import Lottie

final class AnimationScreenViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimation()
    }
    
    private func showAnimation() {
        let animationView = LottieAnimationView(name: "--")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 0.5
        animationView.backgroundColor = .white
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        self.view.addSubview(animationView)
        
        animationView.play { [weak self] _ in
               guard let self = self else { return }
               self.performSegue(withIdentifier: "CategoryTVC", sender: nil)
           }
    }
    
    
}
