//
//  ViewController.swift
//  pokedex
//
//  Created by Aidan Aden on 11/4/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collection: UICollectionView!
    
    var pokemons = [Pokemon]()//array to store all 718 pokemon
    
    var filteredPokemon = [Pokemon]()//array to store filtered pokemon
    var inSearchMode = false
    
    var musicplayer: AVAudioPlayer! //declare audio player
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done //keyboard dismisses after pressing done
        
        parsePokemonCSV()
        initAudio()
        hideKeyboardWhenTappedAround()
    }
    
    func initAudio() { //initializes audio
        
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do {
            
            musicplayer = try AVAudioPlayer(contentsOf: URL(string: path)!)
            musicplayer.prepareToPlay()
            musicplayer.numberOfLoops = -1 //plays non stop
            musicplayer.play()
            
        } catch {
            
            let error = error as NSError
            print(error.debugDescription)
        }
    }
    
    func parsePokemonCSV() { //parses pokemon.csv file to array
        
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")!
        
        do {
            
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeID =  Int(row["id"]!)!
                let name = row["identifier"]!
                
                let poke = Pokemon(name: name, pokedexID: pokeID)
                pokemons.append(poke)
            }
            
        } catch {
            //if error occurs, csv file issue
            let error = error as NSError
            print(error.debugDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let poke: Pokemon!
            
            if inSearchMode {
                
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(poke)
                
            } else {
                
                poke = pokemons[indexPath.row]
                cell.configureCell(poke)
                
            }
            
            return cell
            
        } else {
            
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var poke: Pokemon!
        
        if inSearchMode {
            
            poke = filteredPokemon[indexPath.row]
            
        } else {
            
            poke = pokemons[indexPath.row]
        }
        
        performSegue(withIdentifier: "PokemonDetailsVC", sender: poke)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredPokemon.count
        } else {
            return pokemons.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 105, height: 105)
    }
    
    
    @IBAction func musicBtnPressed(_ sender: Any) {
        
        if musicplayer.isPlaying {
            musicplayer.pause()
            (sender as! UIButton).alpha = 0.2
            
        } else {
            musicplayer.play()
            (sender as! UIButton).alpha = 1.0
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            inSearchMode = false
            collection.reloadData()
            view.endEditing(true)
            
        } else {
            
            inSearchMode = true
            
            let lower = searchBar.text!.lowercased()// $0 refers to each Pokemon class in pokemons array
            filteredPokemon = pokemons.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PokemonDetailsVC" {
            
            if let detailsVC = segue.destination as? PokemonDetailsVC {
                
                if let poke = sender as? Pokemon {
                 
                    detailsVC.pokemon = poke
                }
            }
        }
    }
    
    
    
    
}
