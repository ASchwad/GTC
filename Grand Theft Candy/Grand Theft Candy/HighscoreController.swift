//
//  HighscoreController.swift
//  Grand Theft Candy
//
//  Created by Egeler Lea on 18.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//


import UIKit
import FirebaseDatabase

class HighscoreController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    struct highscoreItem {
        var score : Int
        var name : String
    }
    
    @IBOutlet weak var highscoreTableView: UITableView!
    
    var highscoreTotal: [highscoreItem] = []
    
    @IBOutlet weak var highscoreTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Create Database reference to highscore table
        let rootRef = Database.database().reference(withPath: "highscore")
        //Get data from table
        rootRef.observe(.value, with: { snapshot in
            //Iterate objects and add them to highscoreTotal
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if let value = snap.value as? [String: Any] {
                    let playerName = value["name"] as? String
                    let reachedScore = value["score"] as? Int
                    
                    let singleHighscore = highscoreItem(score: reachedScore!, name: playerName!)
                    
                    self.highscoreTotal.append(singleHighscore);
                }
            }
            //Sort highscoretotal descending
            self.highscoreTotal.sort { $0.score > $1.score }
            //Reload view to actually see retrieved data
            self.highscoreTableView.reloadData()
        })
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //How many rows should the TableView create? TOP 20!
        if(highscoreTotal.count<20){
            return highscoreTotal.count;
        }else{
            return 20;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleEntry", for: indexPath)
        if(highscoreTotal.count>0){
            cell.textLabel?.text = highscoreTotal[indexPath.row].name
            cell.detailTextLabel?.text = "\(highscoreTotal[indexPath.row].score)"
        }
        
        return cell;
    }
}
