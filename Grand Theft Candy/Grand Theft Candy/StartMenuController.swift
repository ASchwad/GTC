//
//  StartMenuController.swift
//  Grand Theft Candy
//
//  Created by Egeler Lea on 12.06.19.
//  Copyright © 2019 Gruppe02. All rights reserved.
//

import UIKit
import AVFoundation

class StartMenuController: UIViewController {
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "gta_sanandreas", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        // fades down volume, can be stopped aswell - but feels to abrupt
        // TODO: await a callback to stop music after fade
        audioPlayer.setVolume(0, fadeDuration: 2)
    }
    
    
}
