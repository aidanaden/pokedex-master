//
//  Pokemon.swift
//  pokedex
//
//  Created by Aidan Aden on 11/4/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexID: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _baseAttack: String!
    private var _nextEvoTxt: String!
    private var _pokemonURL: String!
    private var _nextEvoName: String!
    private var _nextEvoId: String!
    private var _nextEvoLvl: String!
    
    var nextEvoLvl: String {
        
        if _nextEvoLvl == nil {
            _nextEvoLvl = ""
        }
        return _nextEvoLvl
    }
    
    var nextEvoId: String {
        
        if _nextEvoId == nil {
            _nextEvoId = ""
        }
        return _nextEvoId
    }
    
    var nextEvoName: String {
        
        if _nextEvoName == nil {
            _nextEvoName = ""
        }
        return _nextEvoName
    }
    
    var description: String {
        
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense: String {
        
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    
    var height: String {
        
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        
        if _weight == nil {
            
            _weight = ""
        }
        return _weight
    }
    
    var baseAttack: String {
        
        if _baseAttack == nil {
            
            _baseAttack = ""
        }
        return _baseAttack
        
    }
    
    var nextEvoTxt: String {
        
        if _nextEvoTxt == nil {
            
            _nextEvoTxt = ""
        }
        return _nextEvoTxt
        
    }

    var name: String {
        
        return _name
    }
    
    var pokedexID: Int {
        
        return _pokedexID
    }
    
    init(name: String, pokedexID: Int) {
        
        self._name = name
        self._pokedexID = pokedexID
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexID!)/"
    }
    
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        
        Alamofire.request(_pokemonURL).responseJSON { (response) in
            
             if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? String {
                    
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    
                    self._baseAttack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    
                    self._defense = "\(defense)"
                }
                
                if let types = dict["types"] as? [Dictionary<String, String>], types.count > 0 {
                    
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }
                    
                    if types.count > 1 {
                        
                        for x in 1..<types.count {
                            
                            if let name = types[x]["name"] as String! {
                                
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                    
                } else {
                    
                    self._type = ""
                }
                
                if let descriptions = dict["descriptions"] as? [Dictionary<String, String>], descriptions.count > 0 {
                    
                    if let url = descriptions[0]["resource_uri"] {
                        
                        let descURL = "\(URL_BASE)\(url)"
                        
                        Alamofire.request(descURL).responseJSON(completionHandler: { (response) in
                            
                            if let descriptionDict = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let descript = descriptionDict["description"] as? String {
                                    
                                    let newDescription = descript.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    
                                    self._description = newDescription
                                }
                            }
                            
                            completed()
                        })
                    }
                } else {
                    
                    self._description = ""
                }
                
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>], evolutions.count > 0 {
                    
                    if let nextEvo = evolutions[0]["to"] as? String {
                        
                        if nextEvo.range(of: "mega") == nil {
                            
                            self._nextEvoName = nextEvo
                            
                        }
                    }
                    
                    if let uri = evolutions[0]["resource_uri"] as? String {
                        
                        let newString = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                        let nextEvoId = newString.replacingOccurrences(of: "/", with: "")
                        self._nextEvoId = nextEvoId
                        
                    }
                    
                    if let lvlExist = evolutions[0]["level"] {
                        
                        if let level = lvlExist as? Int {
                            
                            self._nextEvoLvl = "\(level)"
                        }
                        
                    } else {
                        
                        self._nextEvoLvl = ""
                    }
                }
                
            }
            completed()
        }
    }
    
    
}











