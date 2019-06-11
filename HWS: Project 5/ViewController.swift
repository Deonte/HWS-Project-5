//
//  ViewController.swift
//  HWS: Project 5
//
//  Created by Deonte on 6/11/19.
//  Copyright © 2019 Deonte. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
   
    var allWords = [String]()
    var usedWords = [String]()
    let cellID = "Word"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        //Challenge 3: Create a new left bar button item that calls startGame()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startwords = try? String(contentsOf: startWordsURL) {
                allWords = startwords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Word", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            //Bug fix: Bug answer would allow the user to enter the same word twice if entered first in Uppercase then once again in lowercase. My Solution was to only acept answers in their lowercased form.
            guard let answer = ac?.textFields?[0].text?.lowercased() else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        // Challenge 1a: Dissallow use of the start word.
        if lowerAnswer != title {
            // Challenge 1b: Dissallow the use of words less than 3 characters
            if lowerAnswer.count >= 3 {
            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        usedWords.insert(answer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        return
                    } else {
                        showErrorMessage(errorTitle: "Word not recognised", errorMessage: "YoU CaN'T jUsT MakE theM Up YoU KnoW!")
                    }
                } else {
                    showErrorMessage(errorTitle: "Word Used Already", errorMessage: "Be more original!")
                }
            } else {
                showErrorMessage(errorTitle: "Word not possible", errorMessage: "You cant spell that word from \(title!.lowercased())")
                }
            } else {
                showErrorMessage(errorTitle: "Need 3 or more letters", errorMessage: "Can't use less than 3 letters.")
            }
        } else {
            showErrorMessage(errorTitle: "No, no, no", errorMessage: "You can't just use the same word.")
        }
        
    }
    
    // Challenge 2: Refactor all the else statements so that they call a new method called showErrorMessage()
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(ac, animated:  true)
    }
    
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased()  else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath )
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
}

