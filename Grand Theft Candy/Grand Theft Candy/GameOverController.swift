//
//  GameOverController.swift
//  Grand Theft Candy
//
//  Created by Egeler Lea on 12.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//


import UIKit
import FirebaseDatabase
import Firebase

class GameOverController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    var score:Int = 0
    
    @IBOutlet weak var submitScore: UIButton!
    @IBAction func submitScoreTouched(_ sender: Any) {
        let alert = UIAlertController(title: "Submit Highscore", message: "Enter your name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Niko Bellic"
        }
        
        //When submit button is pressed
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            
            let ref = Database.database().reference(withPath: "highscore")
            
            //Create unique ID and set Value with score and playerName
            //Unique ID enables multiple entries with the same name
            ref.childByAutoId().setValue(["score": self.score, "name": textField.text!])
            
            //Only allow one submit per game
            self.submitScore.isHidden = true
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "\(score)"
    }
}
