//
//  requeteSQL.swift
//  AppFive
//
//  Created by etudiant on 27/11/2018.
//  Copyright © 2018 L3P-IEM. All rights reserved.
//


import Foundation
import SQLite

class RequeteSQL {
    
    var connect:Connection! // Objet permettant la connexion et manipulation à la base de donnée
    
    let tableRappel = Table("rappel") // Définition de la table Rappel
    
    // Définition des propriétés de la table Stationnement
    let id = Expression<Int>("id")
    let nom = Expression<String>("nom")
    let audio = Expression<String>("audio")
    let time = Expression<String>("time")
    let date = Expression<String>("date")
    let enable = Expression<Bool>("enable")
    
    // Initialise l'objet requete en faisant la connexion et la création (si première utilisation) de la table Stationnement
    init() {
        connexion()
    }
    
    // Permet de faire la connexion à la base de donnée SQLite
    func connexion(){
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:true)
            let fileUrl = documentDirectory.appendingPathComponent("db_remind").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            connect = database
            createTable()
        } catch {
            print(error)
        }
    }
    
    // Création de la table Rappel
    func createTable() {
        let createTable = self.tableRappel.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.nom)
            table.column(self.audio)
            table.column(self.time)
            table.column(self.date)
            table.column(self.enable)
        }
        
        do {
            try self.connect.run(createTable)
        } catch {
            print(error)
        }
    }
    
    func dropTable(){
        let dropTable = self.tableRappel.drop()
        
        do {
            try self.connect.run(dropTable)
        } catch {
            print(error)
        }
    }
    
    // Permet d'ajouter un rappel
    func ajouterRappel(rappel:Rappel) -> Bool {
        // INSERT INTO Rappel VALUES ($nom, $audio, $time, $date, $enable)
        let insert = self.tableRappel.insert(self.nom <- rappel.nom,
                                               self.audio <- rappel.audio,
                                               self.time <- rappel.time,
                                               self.date <- rappel.date,
                                               self.enable <- rappel.enable)
        
        do {
            try self.connect.run(insert)
            print("Le rappel a bien été ajouté.")
            reloadTableView()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    // Permet de modifier un rappel : Nom, Enable
    func modifierRappel(rappel:Rappel){
        let id = rappel.id
        
        // UPDATE Rappel SET nom = $nom, enable = $enable
            // WHERE id = $id
        let filter = self.tableRappel.filter(self.id == id!)
        let update = filter.update(self.nom <- rappel.nom,
                      self.enable <- rappel.enable)
        
        do {
            try self.connect.run(update)
            print("Le rappel a bien été modifié.")
        } catch {
            print(error)
        }
        
        reloadTableView()
    }
    
    // Permet de supprimer un stationnement
    func supprimerRappel(rappel:Rappel){
        let id = rappel.id
        do {
            // DELETE FROM filter_table ( SELECT * FROM Rappel WHERE id = $id )
                // DELETE FROM Rappel WHERE id = $i
            let filter = self.tableRappel.filter(self.id == id!)
            let delete = filter.delete()
            try connect.run(delete)
        } catch {
            print(error)
        }
        reloadTableView()
    }
    
    // Retourne une liste de stationnements enregistrés
    func getRappels() -> [Rappel] {
        var liste = [Rappel]()
        
        do {
            //SELECT * FROM Rappel
            
            let rappels = try self.connect.prepare(tableRappel)
            for line_rappel in rappels {
                let rappel = createObjectRappel(row: line_rappel)
                printRappel(rappel: rappel)
                liste.append(rappel)
            }
        } catch {
            print(error)
        }

        return liste
    }
    
    func getRappel(id:Int) -> Rappel {
        var rappel = Rappel()
        
        do {
            // SELECT * FROM Rappel WHERE id = $id
            let filter = self.tableRappel.filter(self.id == id)
            let select = try self.connect.prepare(filter)
            for row in select {
                rappel = createObjectRappel(row: row)
                //printRappel(rappel: rappel)
            }
        } catch {
            print(error)
        }
        
        return rappel
    }
    
    // Création d'un objet Rappel depuis une ligne de la table Rappel
        // de type Row (SQLite)
    func createObjectRappel(row:Row) -> Rappel {
        
        let id = row[self.id]
        let nom = row[self.nom]
        let audio = row[self.audio]
        let time = row[self.time]
        let date = row[self.date]
        let enable = row[self.enable]
        
        let rappel = Rappel(id: id, nom: nom, date: date, time: time)
        rappel.ajouterAudio(audio: audio)
        
        if(enable){
            rappel.activer()
        } else {
            rappel.desactiver()
        }
        
        return rappel
    }
    
    func printRappel(rappel:Rappel){
        print(" - - - - - - - - - -")
        print("ID: \(String(describing: rappel.id))")
        print("NOM: \(String(describing: rappel.nom))")
        print("DATE: \(String(describing: rappel.date))")
        print("ACTIF: \(rappel.enable)")
        print(" - - - - - - - - - -")
    }
    
    func reloadTableView(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
    }
}
