//
//  SpeechViewController.swift
//  WorkWithSounds
//
//  Created by Aliaksei Strokin on 6/3/19.
//  Copyright © 2019 Alexey Strokin. All rights reserved.
//

import Foundation
import Speech
import AVFoundation
import UIKit

class SpeechViewController: UIViewController {
    
    enum Error: Swift.Error {
        case failed
    }
    
    private lazy var audioEngine = AVAudioEngine()
    
    private lazy var recognizer: SFSpeechRecognizer = {
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru"))
        speechRecognizer?.delegate = self
        return speechRecognizer!
    }()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private lazy var textView: UITextView = {
       let tv = UITextView(frame: .zero)
        tv.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Recognize", for: .normal)
        button.setTitle("Go ahead i'm listening", for: .selected)
        button.addTarget(self, action: #selector(checkPermissions), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -20).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func requestAccessForRecognizer(_ completion: @escaping (Bool) -> ()) {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            let isEnabled: Bool
            switch authStatus {
            case .authorized: isEnabled = true
            case .denied: isEnabled = false
            case .restricted: isEnabled = false
            case .notDetermined: isEnabled = false
            @unknown default:
                isEnabled = false
            }
            completion(isEnabled)
        }
    }
    
    private func stopRecording() {
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
    }
    
    @objc func checkPermissions() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .notDetermined:
            requestAccessForRecognizer { [weak self] (isAuthorized) in
                if isAuthorized {
                    self?.tryToStartRecognition()
                }
            }
        case .authorized:
            tryToStartRecognition()
        case .denied, .restricted:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func tryToStartRecognition() {
        DispatchQueue.main.async {
            do {
                try self.startRecognition()
            } catch {
                let alertController = UIAlertController(title: "SFSpeechRecognizer.Error", message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "Oops", style: .default) { _ in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
            textView.text = nil
            button.isSelected = false
        }
    }
    
    func startRecognition() throws {
        guard  recognizer.isAvailable else { return }
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
            textView.text = nil
            button.isSelected = false
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record)
        try audioSession.setMode(.measurement)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else { throw Error.failed }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        button.isSelected = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false
            
            if let result = result {
                let resultString = result.bestTranscription.formattedString
                
                DispatchQueue.main.async {
                    self?.textView.text = resultString
                    
                    print(resultString)
                    
                    if resultString.localizedCaseInsensitiveContains("хватит баловаться") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                inputNode.removeTap(onBus: 0)
                self?.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        AudioToolbox.beep()
    }
}

extension SpeechViewController: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        print("\(speechRecognizer.debugDescription) available: \(available)")
    }
}
