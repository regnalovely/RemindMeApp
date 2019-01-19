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
    var audio:String!
    
    var sonEnregistre : AVAudioRecorder!
    var sonJouer : AVAudioPlayer!
    var recordingSession : AVAudioSession!
    var fileName : String = "AUD_" + NSUUID().uuidString + ".m4a"
    let requeteSQL = RequeteSQL()
    
    @IBOutlet weak var saisieName: UITextField!
    @IBOutlet weak var enregistreBTN: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saisieName.delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [[.alert, .sound, .badge]], completionHandler: {(granted, error) in
            //Handler Error
        })

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
        enregistreBTN.setTitle("Enregistrer l'audio", for: .normal)
        enregistreBTN.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
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
            
            enregistreBTN.setTitle("Stop", for: .normal)
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
            enregistreBTN.setTitle("Enregistrer à nouveau", for: .normal)
        } else {
            enregistreBTN.setTitle("Enregistrer l'audio", for: .normal)
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
        
        // Création des chaines contenant la date et l'heure du rappel
        let dateRappel = afficherDate(date: date, format: "dd/MM/yyyy")
        let timeRappel = afficherDate(date: date, format: "HH:mm")
        
        //Création du rappel
        let rappel = Rappel(id: 0, nom: saisieName.text!, date: dateRappel, time: timeRappel)
        let reponse = requeteSQL.ajouterRappel(rappel: rappel)
        
        // Si la création dans la base est un succès alors on crée la notification
        if reponse {
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
    
    // Permettre de masquer le clavier lorsqu'on ne souhaite plus faire de saisie dans le textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saisieName.resignFirstResponder()
        return true
    }
}

