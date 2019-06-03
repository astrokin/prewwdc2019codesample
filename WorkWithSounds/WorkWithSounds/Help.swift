
import AudioToolbox

struct AudioToolbox {
   /*work only with unmuted hardware switch
     ignore any volume level*/
   /*No longer than 30 seconds in duration
     In linear PCM or IMA4 (IMA/ADPCM) format
     Packaged in a .caf, .aif, or .wav file*/
    static func play(_ fileName: String, ext: String) {
        guard let path = Bundle.main.resourcePath else { return }
        let url = URL(fileURLWithPath: "\(path)/\(fileName).\(ext)", isDirectory: false)
        
        //Thanks. here is link for all the sound ID : iphonedevwiki.net/index.php/AudioServices 
        var id: SystemSoundID = 0
        
        //The maximum supported duration for a system sound is 30 secs.
        guard AudioServicesCreateSystemSoundID(url as CFURL, &id) == 0 else {
            return
        }
        AudioServicesPlaySystemSoundWithCompletion(id) {
            AudioServicesDisposeSystemSoundID(id)
        }
    }
    
    static func beep() {
        let id: SystemSoundID = 1052
        AudioServicesPlaySystemSoundWithCompletion(id) {
            AudioServicesDisposeSystemSoundID(id)
        }
    }
}

import AVFoundation

struct AVFoundation {
    
    static func playFile(_ fileName: String, ext: String, inBundle: Bool = true) -> AVAudioPlayer? {
        let url: URL?
        if inBundle {
            url = Bundle.main.url(forResource: fileName, withExtension: ext)
        } else {
            url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first?
                .appendingPathComponent(fileName)
                .appendingPathExtension(ext)
        }
        if let fileURL = url {
            return play(fileURL, fileExtension: ext)
        }
        return nil
    }
    /*
     work with any mute switch hardware position
     volume control
     */
    static private func play(_ url: URL, fileExtension: String) -> AVAudioPlayer? {
        do {
            /*
             AVAudioSession.Category
             ambient: //sensitive to mute switch position
             soloAmbient: //sensitive to mute switch position
             playback: //not sensitive to mute switch position
             record: //will not play sound
             playAndRecord: //not sensitive to mute switch position
             multiRoute: //streams of audio data to different output devices at the same time.
            */
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType(fileExtension).rawValue)
            /*By setting this property you can position a sound in the stereo field. A value of –1.0 is full left, 0.0 is center, and 1.0 is full right.*/
            player.pan = 0.0
            /* See enableRate. The playback rate for the sound. 1.0 is normal, 0.5 is half speed, 2.0 is double speed. */
            player.enableRate = true
            player.rate = 1.0 // enableRate MUST be true to take effect
            /* "numberOfLoops" is the number of times that the sound will return to the beginning upon reaching the end.
             A value of zero means to play the sound just once.
             A value of one will result in playing the sound twice, and so on..
             Any negative number will loop indefinitely until stopped.*/
            player.numberOfLoops = 0
            /*A value of 0.0 indicates silence; a value of 1.0 (the default) indicates full volume for the audio player instance.
             Use this property to control an audio player’s volume relative to other audio output */
            player.setVolume(1.0, fadeDuration: 0.1)
            player.prepareToPlay()
            return player
        } catch {
            let alertController = UIAlertController(title: "AVAudioSession.Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Oops", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        return nil
    }
    
    static func record(_ fileName: String, ext: String) -> AVAudioRecorder? {
        let soundFileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent(fileName)
            .appendingPathExtension(ext)
        
        let recordSettings: [String : Any] = [
             AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            let audioRecorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            audioRecorder.prepareToRecord()
            return audioRecorder
        } catch {
            let alertController = UIAlertController(title: "AVAudioSession.Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Oops", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
        return nil
    }
    
    static func deactivate() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            let alertController = UIAlertController(title: "AVAudioSession.Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Oops", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}

import UIKit

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension AVFoundation {
    
    static var availableVoices: [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
    
    static var englishVoices: [AVSpeechSynthesisVoice] {
        return availableVoices.filter({ $0.language.starts(with: "en") })
    }
    
}
