//
//  ViewController.swift
//  testAlarm
//
//  Created by etudiant on 17/01/2019.
//  Copyright © 2019 PAULMIN. All rights reserved.
//

import UIKit
import UserNotifications
import EventKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITextFieldDelegate {
    var date: Date!
    var sonEnregistre : AVAudioRecorder!
    var sonJouer : AVAudioPlayer!
    var recordingSession : AVAudioSession!
    var fileName : String = "AUD_" + NSUUID().uuidString + ".m4a"
    
    @IBOutlet weak var saisieName: UITextField!
    @IBOutlet weak var enregistreBTN: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saisieName.delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .sound, .badge]], completionHandler: {(granted, error) in
            //Handler Error
        })
        // Do any additional setup after loading the view, typically from a nib.
        timePicker.minimumDate = NSDate() as Date
        timePicker.locale = Locale(identifier: "FR_fr")
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    
    func loadRecordingUI() {
        enregistreBTN.setTitle("Tap to Record", for: .normal)
        enregistreBTN.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        enregistreBTN.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(enregistreBTN)
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            sonEnregistre = try AVAudioRecorder(url: audioFilename, settings: settings)
            sonEnregistre.delegate = self
            sonEnregistre.record()
            
            enregistreBTN.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        sonEnregistre.stop()
        sonEnregistre = nil
        
        if success {
            enregistreBTN.setTitle("Tap to Re-record", for: .normal)
        } else {
            enregistreBTN.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if sonEnregistre == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }

// Fonction qui permet de créer la notification

    @IBAction func action(_ sender: Any) {
        date = timePicker.date
        
        // build notification
        let notification = UNMutableNotificationContent()
        notification.title = "Rappel"
        notification.body = "Rappel : \(saisieName.text!)!"
        notification.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "reveil.m4a"))
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate as DateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: notification, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //Fonction pour affiche date correct
    func afficherDate(date:Date, format:String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = format
        let date_ = formatter.string(from:date)
        
        return date_
    }
    
    
    //Bouton Play pour jouer l'audio
    @IBAction func play(_ sender: Any) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            sonJouer = try AVAudioPlayer(contentsOf: url)
            sonJouer.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saisieName.resignFirstResponder()
        return true
    }
}

