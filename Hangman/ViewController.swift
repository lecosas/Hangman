//
//  ViewController.swift
//  Hangman
//
//  Created by user163948 on 4/20/20.
//  Copyright © 2020 lecosas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
     
    @IBOutlet var lbWord: UILabel!
    @IBOutlet var lbUsedWords: UILabel!
    @IBOutlet var lbErrors: UILabel!
    @IBOutlet var btPlay: UIButton!
    
    var usedLetters = [String]() {
        didSet {
            lbUsedWords.text = usedLetters.joined(separator: " ")
        }
    }
    
    var word = ""
    var hideWord = [String]() {
        didSet {
            lbWord.text = hideWord.joined(separator: " ")
        }
    }
    
    var words = [String]()
    
    var wrongLetter = 0 {
        didSet {
            lbErrors.text = "Errors: \(wrongLetter)/7"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let wordsLocal = loadWordsFile() {
            words = wordsLocal
            startGame()
        } else {
            btPlay.isEnabled = false
            lbWord.text = "Error"
            showError(message: "Error to open word's file.")
        }
    }
    
    func startGame() {
        let randomNumber = Int.random(in: 0 ..< words.count)
        word = words[randomNumber].uppercased()
        hideWord.removeAll()
        usedLetters.removeAll()
        
        wrongLetter = 0
        for _ in 0 ..< word.count {
            hideWord.append("_")
        }
        print(word)
    }
    
    func loadWordsFile() -> [String]? {
        
        if let wordFile = Bundle.main.url(forResource: "start", withExtension: ".txt") {
            
            if let wordList = try? String(contentsOf: wordFile) {
                let words = wordList.components(separatedBy: "\n")
                return words
            }
        }
        
        return nil
        
    }
    @IBAction func btPlayOnTouchUpInside(_ sender: Any) {
        let ac = UIAlertController(title: "Type a letter", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.autocapitalizationType = .allCharacters
            textField.keyboardType = .asciiCapable
            textField.textAlignment = .center
            textField.placeholder = "Just one letter"
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] (alert) in
            if var letter = ac?.textFields?[0].text {
                letter = letter.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                self?.playTheGame(letter: letter)
            }
        }
        
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    private func playTheGame(letter: String) {
        if validLetter(letter) {
            usedLetters.append(letter)
                       
            let indices = word.indices(of: letter)
            if indices.count > 0 {
                for index in indices {
                    hideWord[index] = letter
                }
                if !hideWord.contains("_") {
                    showAlert(title: "Congratulations", message: "You found out the word: \(word).")
                    startGame()
                }
                
            } else {
                wrongLetter += 1
                
                if wrongLetter >= 7 {
                    showAlert(title: "Game Over", message: "Game over. The word was: \(word).")
                    startGame()
                } else {
                    showError(message: "The letters does not exists in the word.")
                }
            }
        }
    }
    
    private func validLetter(_ letter: String) -> Bool {
        if letter.count > 1 {
            showError(message: "Type just one letter.")
            return false
        } else if letter.count < 1 {
            showError(message: "A letter is needed.")
            return false
        } else if !Character(letter).isLetter {
            showError(message: "Just letter is permitted.")
            return false
        } else if usedLetters.contains(letter) {
            showError(message: "Letter's already used.")
            return false
        }
        
        return true
        
    }
    
    private func showError(message: String) {
        let ac = UIAlertController(title: "Invalid answer", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
}

