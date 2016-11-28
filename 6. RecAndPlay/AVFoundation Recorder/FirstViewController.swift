//
//  FirstViewController.swift
//  Welcome
//
//  Created by ChoiYunho on 11/27/16.
//  Copyright © 2016 Gene De Lisa. All rights reserved.
//

import UIKit
import AVFoundation

class FirstViewController: UIViewController {
    
    var player:AVAudioPlayer!
    var audioPlayer = AVAudioPlayer()
    var soundFileURL:URL!
    var count = AVAudioPlayer()


    override func viewDidLoad() {
        super.viewDidLoad()

        //audioPlayer
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:Bundle.main.path(forResource: "h9301", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1;
            audioPlayer.play()
            //load count.mp3
            count = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:Bundle.main.path(forResource: "count", ofType: "mp3")!))
            count.prepareToPlay()
        }
        catch{ // catch errors
            print(error)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnAction(_ sender: Any) {
        audioPlayer.stop()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
