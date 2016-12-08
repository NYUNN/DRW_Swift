//
//  RecorderViewController.swift
//  SwiftAVFound
//
//  Created by Gene De Lisa on 8/11/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.

import UIKit
import AVFoundation
//audiotoolbox

/**

Uses AVAudioRecorder to record a sound file and an AVAudioPlayer to play it back.

- Author: Gene De Lisa

*/

class RecorderViewController: UIViewController,UITextFieldDelegate {
    
    var recorder: AVAudioRecorder!
    
    var player:AVAudioPlayer!
    //background music
    var audioPlayer = AVAudioPlayer()
    //count
    var count = AVAudioPlayer()
    
    
    @IBOutlet public var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    
    var meterTimer:Timer!
    var countTimer:Timer!
    var soundFileURL:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        record()

        //audioPlayer
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:Bundle.main.path(forResource: "h9301", ofType: "mp3")!))
            audioPlayer.prepareToPlay()
            audioPlayer.numberOfLoops = -1;
            audioPlayer.play()
            //load count.mp3
            count = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:Bundle.main.path(forResource: "count", ofType: "mp3")!))
            count.prepareToPlay()
            count.play()
        }
        catch{ // catch errors
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "goplay" {
            let vc2 = segue.destination as! PlayController
            vc2.soundFileURL = self.recorder.url
            vc2.previousViewController = self
        }
    }

    func updateAudioMeter(_ timer:Timer) {
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            statusLabel.text = s
            recorder.updateMeters()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
    }
    
    @IBAction func removeAll(_ sender: AnyObject) {
        deleteAllRecordings()
    }
    
    //record
    func recordVoice() {
        recordButton.isEnabled = true
        audioPlayer.play() //Backgound sound
        recordButton.setTitle("Stop", for:UIControlState())
        playButton.isEnabled = false
        recordWithPermission(true)    // record!!
    }
    
    func record() {
        
        if player != nil && player.isPlaying {
            //player.stop()
        }
            //record after 5 seconds
            recordButton.isEnabled = false
            let countTimer : Timer = Timer.scheduledTimer(timeInterval:5, target: self, selector: #selector(self.recordVoice), userInfo: nil, repeats: false)
            return
        
        //if recorder != nil && recorder.isRecording { //not activated
        //}
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        print(" when clicked while recording")

        recorder?.stop()
        player?.stop()
        audioPlayer.stop()
        meterTimer.invalidate()
        
        let session = AVAudioSession.sharedInstance() // let : similar with var
        do {
            try session.setActive(false)
            playButton.isEnabled = true
            recordButton.isEnabled = true
            playButton.setTitle("Play", for:UIControlState())
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
    }
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var testTextField: UITextField!
    
    let userDefaults = UserDefaults.standard
    
    /* recording file */
    
    func setupRecorder() {
        
        let format = DateFormatter()
        //Customize file name
        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.string(from: Date())).m4a"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")

        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }

        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey:             NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVEncoderBitRateKey :      NSNumber(value:320000),
            AVNumberOfChannelsKey:     NSNumber(value:2),
            AVSampleRateKey :          NSNumber(value:44100.0)
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
    }
    
    func recordWithPermission(_ setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                        target:self,
                        selector:#selector(RecorderViewController.updateAudioMeter(_:)),
                        userInfo:nil,
                        repeats:true)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
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
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
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
    
    func deleteAllRecordings() {
        let docsDir =
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing\(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
    }
    
    func askForNotifications() {
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(RecorderViewController.background(_:)),
            name:NSNotification.Name.UIApplicationWillResignActive,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(RecorderViewController.foreground(_:)),
            name:NSNotification.Name.UIApplicationWillEnterForeground,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(RecorderViewController.routeChange(_:)),
            name:NSNotification.Name.AVAudioSessionRouteChange,
            object:nil)
    }
    
    func background(_ notification:Notification) {
        print("background")
    }
    
    func foreground(_ notification:Notification) {
        print("foreground")
    }
    
    func routeChange(_ notification:Notification) {
        print("routeChange \((notification as NSNotification).userInfo)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                }
            }
        }
    }
    
    func checkHeadphones() {
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    @IBAction
    
    func trim() {
        if self.soundFileURL == nil {
            print("no sound file")
            return
        }
        
        print("trimming \(soundFileURL!.absoluteString)")
        print("trimming path \(soundFileURL!.lastPathComponent)")
        let asset = AVAsset(url:self.soundFileURL!)
        exportAsset(asset, fileName: "trimmed.m4a")
    }
    
    func exportAsset(_ asset:AVAsset, fileName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        print("saving to \(trimmedSoundFileURL.absoluteString)")

        if FileManager.default.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists, removing \(trimmedSoundFileURL.absoluteString)")
            do {
                if try trimmedSoundFileURL.checkResourceIsReachable() {
                    print("is reachable")
                }
                
                try FileManager.default.removeItem(atPath: trimmedSoundFileURL.absoluteString)
            } catch let error as NSError {
                NSLog("could not remove \(trimmedSoundFileURL)")
                print(error.localizedDescription)
            }
        }
        
        print("creating export session for \(asset)")

        //FIXME: this is failing. the url looks ok, the asset is ok, the recording settings look ok, so wtf?
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileTypeAppleM4A
            exporter.outputURL = trimmedSoundFileURL
            
            let duration = CMTimeGetSeconds(asset.duration)
            if (duration < 5.0) {
                print("sound is not long enough")
                return
            }
            // e.g. the first 5 seconds
            let startTime = CMTimeMake(0, 1)
            let stopTime = CMTimeMake(5, 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            
//            // set up the audio mix
//            let tracks = asset.tracksWithMediaType(AVMediaTypeAudio)
//            if tracks.count == 0 {
//                return
//            }
//            let track = tracks[0]
//            let exportAudioMix = AVMutableAudioMix()
//            let exportAudioMixInputParameters =
//            AVMutableAudioMixInputParameters(track: track)
//            exportAudioMixInputParameters.setVolume(1.0, atTime: CMTimeMake(0, 1))
//            exportAudioMix.inputParameters = [exportAudioMixInputParameters]
//            // exporter.audioMix = exportAudioMix
            
            // do it
            exporter.exportAsynchronously(completionHandler: {
                print("export complete \(exporter.status)")

                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:

                    if let e = exporter.error as? NSError {
                        print("export failed \(e)")
                        switch e.code {
                        case AVError.Code.fileAlreadyExists.rawValue:
                            print("File Exists")
                            break
                        default: break
                        }
                    } else {
                        print("export failed")
                    }
                case AVAssetExportSessionStatus.cancelled:
                    print("export cancelled \(exporter.error)")
                default:
                    print("export complete")
                }
            })
        } else {
            print("cannot create AVAssetExportSession for asset \(asset)")
        }
        
    }
    
    @IBAction
    func speed() {
        let asset = AVAsset(url:self.soundFileURL!)
        exportSpeedAsset(asset, fileName: "trimmed.m4a")
    }
    
    func exportSpeedAsset(_ asset:AVAsset, fileName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let trimmedSoundFileURL = documentsDirectory.appendingPathComponent(fileName)
        
        let filemanager = FileManager.default
        if filemanager.fileExists(atPath: trimmedSoundFileURL.absoluteString) {
            print("sound exists")
        }
        
        print("creating export session for \(asset)")

        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileTypeAppleM4A
            exporter.outputURL = trimmedSoundFileURL
            exporter.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmVarispeed
            
            let duration = CMTimeGetSeconds(asset.duration)
            if (duration < 5.0) {
                print("sound is not long enough")
                return
            }
            
            // do it
            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:
                    print("export failed \(exporter.error)")
                case AVAssetExportSessionStatus.cancelled:
                    print("export cancelled \(exporter.error)")
                default:
                    print("export complete")
                }
            })
        }
    }
}

// MARK: AVAudioRecorderDelegate
extension RecorderViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
        successfully flag: Bool) {
            print("finished recording \(flag)")
            playButton.isEnabled = true
            recordButton.setTitle("Record", for:UIControlState())
            
            // iOS8 and later
        /*
            let alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .default, handler: {action in
                print("keep was tapped")
                self.recorder = nil
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in
                print("delete was tapped")
                self.recorder.deleteRecording()
            }))
            self.present(alert, animated:true, completion:nil)*/
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
        error: Error?) {
            
            if let e = error {
                print("\(e.localizedDescription)")
            }
    }
}

// MARK: AVAudioPlayerDelegate
extension RecorderViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        recordButton.isEnabled = true
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
    
}

