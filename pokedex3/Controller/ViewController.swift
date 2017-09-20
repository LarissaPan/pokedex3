//
//  ViewController.swift
//  pokedex3
//
//  Created by WEN LING PAN on 8/25/17.
//  Copyright © 2017 WEN LING PAN. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon = [Pokemon]()
    var musicPlayer:AVAudioPlayer!
    var filteredPokemon = [Pokemon]()
    var inSearchMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.dataSource = self
        collection.delegate = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        parsePokemonCSV()
        initAudio()
    }
    
    
    func initAudio() {
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")
        do{
            musicPlayer = try AVAudioPlayer(contentsOf: URL(string:path!)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
        }catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    func parsePokemonCSV() {
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")
        do {
            let csv = try String(contentsOfFile: path!, encoding: .utf8)
            let prerows = cleanRows(file: csv)
            var rows = prerows.components(separatedBy: "\n")
            
            rows.remove(at: 0)
            rows.remove(at: 718)
            
            for row in rows {
                let col = row.components(separatedBy: ",")

                    let pokeId = Int(col[0])!
                    let name = col[1]
                    let poke = Pokemon(name: name, pokedexId: pokeId)
                    pokemon.append(poke)
                print ("\(pokeId), \(name)")
          
            }
            
            
        } catch let err as NSError {
            print (err.debugDescription)
        }
    }
    
    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
 

        return cleanFile
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let poke:Pokemon!
            
            if inSearchMode {
                poke = filteredPokemon[indexPath.row]
                cell.configureCell(pokemon: poke)
                
            } else {
                poke = pokemon[indexPath.row]
                cell.configureCell(pokemon: poke)
            }
            
            
            return cell
            
        }else {
            
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var poke:Pokemon!
        
        if inSearchMode {
            poke = filteredPokemon[indexPath.row]
        } else {
            poke = pokemon[indexPath.row]
        }
        
        performSegue(withIdentifier: "PokemonDetailVC", sender: poke)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredPokemon.count
        }
        return pokemon.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width:105, height:105)
    }


    @IBAction func musicBtnPressed(_ sender: UIButton) {
        if musicPlayer.isPlaying {
            musicPlayer.pause()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            collection.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            filteredPokemon = pokemon.filter({$0.name.range(of: lower) != nil  })
            collection.reloadData()
        }
        
        
        
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destination as? PokemonDetailVC {
                if let poke =  sender as? Pokemon {
                    detailsVC.pokemon = poke
                }
            }
        }
    }

}

