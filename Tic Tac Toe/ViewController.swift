//
//  ViewController.swift
//  Tic Tac Toe
//
//  Created by Eric De Smedt on 02/01/2018.
//  Copyright © 2018 Tom De Smedt. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    var joueur = 1 //Cross
    var etatJeu = [0,0,0,0,0,0,0,0,0]
    let conditionVictoire = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
    var enJeu = true
    var database: Connection!
    var nv = 0
    var  nr = 0
    var ne = 0
    var np = 0
    let victoireTable = Table("victoire")
    let victoire = Expression<Int>("victoire")
    let rond = Expression<Int>("rond")
    let egalite = Expression<Int>("egalite")
    let partie = Expression<Int>("partie")
    @IBOutlet weak var vainqueur: UILabel!
    @IBOutlet weak var nombreVictoire: UILabel?
    @IBOutlet weak var nombreVictoireRond: UILabel?
    @IBOutlet weak var nombreMatchNul: UILabel?
    @IBOutlet weak var nombrePartie: UILabel?

    

    @IBAction func action(_ sender: AnyObject) {
        if(etatJeu[sender.tag - 1] == 0 && enJeu == true){

            etatJeu[sender.tag-1] = joueur
            
            if(joueur == 1){
                sender.setImage(UIImage(named: "Croix.jpg"), for: UIControlState())
                joueur = 2
            }
                
            else{
                sender.setImage(UIImage(named: "nought.png"), for: UIControlState())
                joueur = 1
            }
        }
        
        for combinaison in conditionVictoire{
            if(etatJeu[combinaison[0]] != 0 && etatJeu[combinaison[0]] == etatJeu[combinaison[1]] && etatJeu[combinaison[1]] ==     etatJeu[combinaison[2]]){
                enJeu = false
                if(etatJeu[combinaison[0]] == 1){
                    vainqueur.text = "CROIX GAGNE"
                    let updateVictoire = self.victoireTable.update(self.victoire <- self.victoire+1)
                    do{
                        try self.database.run(updateVictoire)
                    }catch{
                        print(error)
                    }
                    do{
                        for v in try database.prepare(victoireTable){
                            nv = v[victoire]
                        }
                    }catch{
                        print(error)
                    }
                    let updatePartie = self.victoireTable.update(self.partie <- self.partie+1)
                    do{
                        try self.database.run(updatePartie)
                    }catch{
                        print(error)
                    }
                    do{
                        for p in try database.prepare(victoireTable){
                            np = p[partie]
                        }
                    }catch{
                        print(error)
                    }
                }
                else{
                    vainqueur.text = "ROND GAGNE"
                    let updateVictoireRond = self.victoireTable.update(self.rond <- self.rond+1)
                    do{
                        try self.database.run(updateVictoireRond)
                    }catch{
                        print(error)
                    }
                    do{
                        for r in try database.prepare(victoireTable){
                            nr = r[rond]
                        }
                    }catch{
                        print(error)
                    }
                    let updatePartie = self.victoireTable.update(self.partie <- self.partie+1)
                    do{
                        try self.database.run(updatePartie)
                    }catch{
                        print(error)
                    }
                    do{
                        for p in try database.prepare(victoireTable){
                            np = p[partie]
                        }
                    }catch{
                        print(error)
                    }
                }
                boutonRejouer.isHidden = false
                vainqueur.isHidden = false
            }
            
        }
        var count = 1
        
        if enJeu == true{
            for i in etatJeu{
                count = i*count
            }
            if count != 0
            {
                vainqueur.text = "Match Nul"
                vainqueur.isHidden = false
                boutonRejouer.isHidden = false
                let updateEgalite = self.victoireTable.update(self.egalite <- self.egalite+1)
                do{
                    try self.database.run(updateEgalite)
                }catch{
                    print(error)
                }
                do{
                    for e in try database.prepare(victoireTable){
                        ne = e[egalite]
                    }
                }catch{
                    print(error)
                }
                let updatePartie = self.victoireTable.update(self.partie <- self.partie+1)
                do{
                    try self.database.run(updatePartie)
                }catch{
                    print(error)
                }
                do{
                    for p in try database.prepare(victoireTable){
                        np = p[partie]
                    }
                }catch{
                    print(error)
                }
            }
        }
    }
    
    @IBOutlet weak var boutonRejouer: UIButton!
    @IBAction func rejouer(_ sender: UIButton) {
        etatJeu = [0,0,0,0,0,0,0,0,0]
        enJeu = true
        joueur = 1
        
        boutonRejouer.isHidden = true
        vainqueur.isHidden = true
        
        for i in 1...9{
            let bouton = view.viewWithTag(i) as! UIButton
            bouton.setImage(nil, for: UIControlState())
        }
        
    }
    

    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        }catch{
            print(error)
        }
        let createTable = self.victoireTable.create { (table) in
            table.column(self.victoire)
            table.column(self.rond)
            table.column(self.egalite)
            table.column(self.partie)
        }
        do{
            try self.database.run(createTable)
        } catch{
            print(error)
        }
        let insertMode = self.victoireTable.insert(self.victoire <- 0, self.rond <- 0, self.egalite <- 0, self.partie <- 0)
        do{
                    try self.database.run(insertMode)
            
        } catch{
            print(error)
        }
        do{
            for v in try database.prepare(victoireTable){
                if(nv <= v[victoire]){
                    nv = v[victoire]
                    nr = v[rond]
                    ne = v[egalite]
                    np = v[partie]
                    
                }
                nombreVictoire?.text = String(nv)
                nombreVictoireRond?.text = String(nr)
                nombreMatchNul?.text = String(ne)
                nombrePartie?.text = String(np)
            }
        }catch{
            print(error)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

