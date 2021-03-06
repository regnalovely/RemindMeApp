//
//  rappel.swift
//  RemindMeApp
//
//  Created by etudiant on 18/01/2019.
//  Copyright © 2019 L3P-IEM. All rights reserved.
//

import Foundation

class Rappel {
    var id:Int!
    var nom:String!
    var audio:String!
    var date:String!
    var time:String!
    var enable:Bool = false
    
    init(){
        id = Int()
        nom = String()
        audio = String()
        date = String()
        time = String()
    }
    
    init(id:Int, nom:String, date:String, time:String){
        self.id = id
        self.nom = nom
        self.date = date
        self.time = time
    }
    
    func ajouterAudio(audio:String){
        self.audio = audio
    }
    
    func getRappel() -> Int {
        return id
    }
    
    func getName() -> String {
        return nom
    }
    
    func getDate() -> String {
        return date
    }
    
    func getTime() -> String {
        return time
    }
    
    func getAudio() -> String {
        return audio
    }
    
    func getState() -> Bool {
        return enable
    }
    
    func activer() {
        enable = true
    }
    
    func desactiver() {
        enable = false
    }
}
