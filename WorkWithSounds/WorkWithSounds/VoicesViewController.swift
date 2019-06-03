//
//  VoicesViewController.swift
//  WorkWithSounds
//
//  Created by Aliaksei Strokin on 6/3/19.
//  Copyright © 2019 Alexey Strokin. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VoicesViewController: UIViewController {
    
    private lazy var synthesizer: AVSpeechSynthesizer = {
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        return synthesizer
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: self.view.bounds)
        pickerView.delegate = self
        pickerView.dataSource = self
        
        return pickerView
    }()
    
    lazy var utterranceLabel: UILabel = {
        var label = UILabel(frame: self.view.bounds)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var transliterationLabel: UILabel = {
        var label = UILabel(frame: self.view.bounds)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var stackView: UIStackView = {
        var stackView = UIStackView(frame: self.view.bounds)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        stackView.addArrangedSubview(self.pickerView)
        stackView.addArrangedSubview(self.utterranceLabel)
        stackView.addArrangedSubview(self.transliterationLabel)
        
        return stackView
    }()
    
    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    public override func loadView() {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 320.0, height: 400)))
        view.backgroundColor = .white
        self.view = view
        
        self.view.addSubview(self.stackView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let randomRow = (0..<LanguageSample.all.endIndex).randomElement()!
        self.pickerView.selectRow(randomRow, inComponent: 0, animated: false)
        self.pickerView(self.pickerView, didSelectRow: randomRow, inComponent: 0)
    }
}

extension VoicesViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return LanguageSample.all.count
    }
}

extension VoicesViewController: UIPickerViewDelegate {
    // MARK: UIPickerViewDelegate
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let sample = LanguageSample.all[row]
        
        let localizedLanguageName = Locale.current.localizedString(forLanguageCode: sample.languageCode)!
        
        return "\(localizedLanguageName) (\(sample.languageCode))"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.synthesizer.stopSpeaking(at: .immediate)
        
        let sample = LanguageSample.all[row]
        self.utterranceLabel.text = sample.text
        self.transliterationLabel.text = sample.transliteratedText
        
        let utterance = AVSpeechUtterance(string: sample.text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
        utterance.preUtteranceDelay = 0.25;
        utterance.postUtteranceDelay = 0.25;
        utterance.voice = AVSpeechSynthesisVoice(language: sample.languageCode)
        
        self.synthesizer.speak(utterance)
    }
}

extension VoicesViewController: AVSpeechSynthesizerDelegate {
    private func attributedString(from string: String, highlighting characterRange: NSRange) -> NSAttributedString {
        guard characterRange.location != NSNotFound else {
            return NSAttributedString(string: string)
        }
        
        let mutableAttributedString = NSMutableAttributedString(string: string)
        mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.red, range: characterRange)
        return mutableAttributedString
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        self.utterranceLabel.attributedText = attributedString(from: utterance.speechString, highlighting: characterRange)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.utterranceLabel.attributedText = NSAttributedString(string: utterance.speechString)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.utterranceLabel.attributedText = NSAttributedString(string: utterance.speechString)
    }
}

import NaturalLanguage

let samplesByLanguage: [NLLanguage: String] = [
    .arabic: "لَيْسَ حَيَّاً مَنْ لَا يَحْلُمْ",
    .czech: "Kolik jazyků znáš, tolikrát jsi člověkem.",
    .danish: "Enhver er sin egen lykkes smed.",
    .dutch: "Wie zijn eigen tuintje wiedt, ziet het onkruid van een ander niet",
    .german: "Die beste Bildung findet ein gescheiter Mensch auf Reisen.",
    .greek: "Ἐν οἴνῳ ἀλήθεια",
    .english: "All the world's a stage, and all the men and women merely players",
    .finnish: "On vähäkin tyhjää parempi.",
    .french: "Le plus grand faible des hommes, c'est l'amour qu'ils ont de lavie.",
    .hindi: "जान है तो जहान है",
    .hungarian: "Ki korán kel, aranyat lel|Aki korán kel, aranyat lel.",
    .indonesian: "Jadilah kumbang, hidup sekali di taman bunga, jangan jadi lalat hidup:skali di bukit sampah.",
    .italian: "Finché c'è vita c'è speranza.",
    .japanese: "天に星、地に花、人に愛",
    .korean: "손바닥으로 하늘을 가리려한다",
    .norwegian: "D'er mange ǿksarhogg, som eiki skal fella.",
    .polish: "Co lekko przyszło, lekko pójdzie.",
    .portuguese: "É de pequenino que se torce o pepino.",
    .romanian: "Cine se scoală de dimineață, departe ajunge.",
    .russian: "Челове́к рожда́ется жить, а не гото́виться к жи́зни.",
    .slovak: "Každy je sám svôjho št'astia kováč.",
    .spanish: "La vida no es la que uno vivió, sino la que uno recuerda, y cómola recu:ra para contarla.",
    .swedish: "Verkligheten överträffar dikten.",
    .thai: "ความลับไม่มีในโลก",
    .turkish: "Al elmaya taş atan çok olur.",
    .simplifiedChinese: "小洞不补，大洞吃苦。",
    .traditionalChinese: "風向轉變時、\n有人築牆、\n有人造風車。"
]

public struct LanguageSample: Equatable, Hashable {
    public static let all: [LanguageSample] = {
        return samplesByLanguage.map {
            LanguageSample(language: $0.0, text: $0.1)
            }.sorted()
    }()
    
    public let languageCode: String
    public let text: String
    public let transliteratedText: String?
    
    init(language: NLLanguage, text: String) {
        self.languageCode = language.rawValue
        self.text = text
        
        if let transliteratedText = text.applyingTransform(.toLatin, reverse: false),
            text != transliteratedText
        {
            self.transliteratedText = transliteratedText
        } else {
            self.transliteratedText = nil
        }
    }
}

extension LanguageSample: Comparable {
    public static func < (lhs: LanguageSample, rhs: LanguageSample) -> Bool {
        return lhs.languageCode < rhs.languageCode
    }
}
