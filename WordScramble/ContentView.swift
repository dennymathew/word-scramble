//
//  ContentView.swift
//  WordScramble
//
//  Created by Denny Mathew on 21/11/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var points: Int = 0
    @State private var turns = 0
    @State private var nextButtonTitle = "Next word"
    private let maxTurns = 10
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
                    .padding()
                List(usedWords, id:\.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0.uppercased())
                }
                Text("Your points")
                    .foregroundColor(.orange)
                Text("\(points)")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.orange)
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startGame, label: {
                Text(nextButtonTitle)
            })
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .clipShape(Capsule())
            )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    func reset() {
        turns = 0
        points = 0
    }
    func startGame() {
        guard turns != maxTurns else {
            errorTitle = "Game over"
            errorMessage = "You have scored \(points) points!"
            nextButtonTitle = "Next word"
            showingError = true
            reset()
            return
        }
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String.init(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = (allWords.randomElement() ?? "silkworm").uppercased()
                usedWords.removeAll()
                turns += 1
                if turns == maxTurns {
                    nextButtonTitle = "End game"
                }
                return
            }
            fatalError("Couldn't load text file from bundle!")
        }
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word.lowercased())
    }
    func isPossible(word: String) -> Bool {
        var tempWord = self.rootWord.lowercased()
        for letter in word.lowercased() {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !answer.isEmpty else {
            return
        }
        // Original?
        guard isOriginal(word: newWord) else {
            wordError(title: "Already used", message: "Be more original.")
            return
        }
        // Real?
        guard isReal(word: newWord) else {
            wordError(title: "Word not recognized", message: "That isn't a real word!")
            return
        }
        // Possible?
        guard isPossible(word: newWord) else {
            wordError(title: "Word not possible", message: "You can't just make them up! You know.")
            return
        }
        addToPoints(word: newWord)
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        newWord = ""
        showingError = true
    }
    func addToPoints(word: String) {
        points += word.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
