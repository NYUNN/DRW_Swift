//
//  PlayController.swift
//  Welcome
//
//  Created by ChoiYunho on 11/28/16.
//  Copyright © 2016 Gene De Lisa. All rights reserved.
//

import UIKit
import AVFoundation

class PlayController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet var playButton: UIButton!
    var player:AVAudioPlayer!
    var audioPlayer = AVAudioPlayer()
    var soundFileURL:URL!
    var previousViewController: RecorderViewController!
    
    //var recorder = RecorderViewController().transferViewControllerVariables()

    override func viewDidLoad() {
        super.viewDidLoad()
        playVoice()
        // Do any additional setup after loading the view.
     
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playVoiceT() {
        setSessionPlayback()
        play()
 
        
    }
    
    func playVoice(){
        
        playButton.isEnabled = false
        let countTimer : Timer = Timer.scheduledTimer(timeInterval:2, target: self, selector: #selector(self.playVoiceT), userInfo: nil, repeats: false)
        return
    }
    
    @IBAction func play(_ sender: UIButton) {
    }
    
    
    /*
     func play(url: NSURL) {
     let item = AVPlayerItem(URL: url)
     
     NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
     
     let player = AVPlayer(playerItem: item)
     player.play()
     }
     
     func playerDidFinishPlaying(note: NSNotification) {
     // Your code here
     }
     */
    
    func play() {
        
        var url:URL?
        url = self.soundFileURL!
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("ended")
        playButton.isEnabled = true
    }
    
    func setSessionPlayback() {
        //Returns the singleton audio session.
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        //error handling
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
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
