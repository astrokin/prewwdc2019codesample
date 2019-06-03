//
//  ViewController.swift
//  WorkWithSounds
//
//  Created by Aliaksei Strokin on 5/13/19.
//  Copyright © 2019 Alexey Strokin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var player: AVAudioPlayer? {
        didSet {
            player?.delegate = self
        }
    }
    
    @IBOutlet var recordButton: UIButton!
    var audioRecorder: AVAudioRecorder? {
        didSet {
            audioRecorder?.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func audiotoolbox(_ sender: Any) {
        AudioToolbox.play("гуси-гуси-га-га-га", ext: "mp3")
    }
    
    @IBAction func avfoundation(_ sender: Any) {
        if player?.isPlaying ?? false {
            player?.stop()
            player = nil
        }
        player = AVFoundation.playFile("гуси-гуси-га-га-га", ext: "mp3")
        player?.play()
        ///please remeber to deactivate AVAudioSession if no longer used
        ///in audioPlayerDidFinishPlaying
        ///you are not alone here :)
    }
    
    @IBAction func vibrate(_ sender: Any) {
        UIDevice.vibrate()
    }
    
    @IBAction func impact(_ sender: Any) {
        let light = UIImpactFeedbackGenerator(style: .light)
        light.prepare()
        light.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let medium = UIImpactFeedbackGenerator(style: .medium)
            medium.prepare()
            medium.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                let heavy = UIImpactFeedbackGenerator(style: .heavy)
                heavy.prepare()
                heavy.impactOccurred()
            }
        }
    }
    
    @IBAction func selection(_ sender: Any) {
        let selection = UISelectionFeedbackGenerator()
        selection.prepare()
        selection.selectionChanged()
    }
    
    @IBAction func notification(_ sender: Any) {
        let success = UINotificationFeedbackGenerator()
        success.prepare()
        success.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            let warning = UINotificationFeedbackGenerator()
            warning.prepare()
            warning.notificationOccurred(.warning)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                let error = UINotificationFeedbackGenerator()
                error.prepare()
                error.notificationOccurred(.error)
            }
        }
    }
    
    @IBAction func record(_ sender: UIButton) {
        if let audioRecorder = audioRecorder {
            if audioRecorder.isRecording {
                audioRecorder.stop()
            }
            if player?.isPlaying ?? false {
                player?.stop()
                player = nil
            }
            player = AVFoundation.playFile("Jobs", ext: "caf", inBundle: false)
            player?.play()
            self.audioRecorder = nil
            return
        }
        recordButton.isSelected = true
        audioRecorder = AVFoundation.record("Jobs", ext: "caf")
        audioRecorder?.record()
    }
    
    @IBAction func voices(_ sender: Any) {
        let vc = VoicesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func speech(_ sender: Any) {
        let vc = SpeechViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let rec = audioRecorder, rec.isRecording {
            return
        }
        AVFoundation.deactivate()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        let alertController = UIAlertController(title: "AVAudioPlayer.Error", message: error?.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Oops", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.isSelected = false
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        audioRecorder = nil
        recordButton.isSelected = false
        let alertController = UIAlertController(title: "AVAudioRecorder.Error", message: error?.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Oops", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}
