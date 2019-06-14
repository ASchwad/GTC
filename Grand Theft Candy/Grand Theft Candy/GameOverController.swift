//
//  GameOverController.swift
//  Grand Theft Candy
//
//  Created by Egeler Lea on 12.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//


import UIKit
import AVFoundation

class GameOverController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    var score:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "\(score)"
    }
}
