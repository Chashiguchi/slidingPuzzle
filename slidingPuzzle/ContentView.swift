//
//  ContentView.swift
//  slidingPuzzle
//
//  Created by Chase Hashiguchi on 1/23/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        PuzzleViewControllerWrapper()
            .edgesIgnoringSafeArea(.all) // Optional: To make the puzzle cover the entire screen
    }
}

#Preview {
    ContentView()
}

struct PuzzleViewControllerWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> ViewController {
        // Return the instance of your custom ViewController
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Optionally, update your UIViewController if needed
    }
}

class ViewController: UIViewController {

    var buttons: [UIButton] = []
    var emptySpaceIndex = 8  // 0-indexed position for 3x3 grid (empty space at last)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the game board
        setupPuzzle()
    }
    
    func setupPuzzle() {
        let gridSize = 3 // 3x3 grid
        let buttonSize: CGFloat = 100.0
        let padding: CGFloat = 10.0
        let startingNumbers = (1..<9).shuffled() + [0] // Numbers 1-8 shuffled with 0 representing empty space
        
        let totalWidth = CGFloat(gridSize) * buttonSize + CGFloat(gridSize - 1) * padding
        let totalHeight = CGFloat(gridSize) * buttonSize + CGFloat(gridSize - 1) * padding
        
        let startX = (self.view.frame.width - totalWidth) / 2
        let startY = (self.view.frame.height - totalHeight) / 2
        
        for i in 0..<gridSize * gridSize {
            let row = i / gridSize
            let col = i % gridSize
            let button = UIButton(type: .system)
            
            let x = startX + CGFloat(col) * (buttonSize + padding)
            let y = startY + CGFloat(row) * (buttonSize + padding)
            
            button.frame = CGRect(x: x, y: y, width: buttonSize, height: buttonSize)
            
            // Set up button actions
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            button.backgroundColor = UIColor.lightGray
            
            // Set button titles or images
            if startingNumbers[i] != 0 {
                button.setTitle("\(startingNumbers[i])", for: .normal)
            } else {
                button.setTitle("", for: .normal)
            }
            
            // Add to view
            self.view.addSubview(button)
            buttons.append(button)
        }
    }

    
    @objc func buttonTapped(_ sender: UIButton) {
        let tappedIndex = sender.tag
        
        // Find the empty space's position
        let emptyRow = emptySpaceIndex / 3
        let emptyCol = emptySpaceIndex % 3
        let tappedRow = tappedIndex / 3
        let tappedCol = tappedIndex % 3
        
        // Check if the tapped button is adjacent to the empty space
        if (abs(emptyRow - tappedRow) == 1 && emptyCol == tappedCol) || (abs(emptyCol - tappedCol) == 1 && emptyRow == tappedRow) {
            // Swap the tapped button and the empty space
            swapButtons(tappedIndex)
        }
    }
    
    func swapButtons(_ tappedIndex: Int) {
        // Update empty space index
        let tappedButton = buttons[tappedIndex]
        buttons[emptySpaceIndex].setTitle(tappedButton.title(for: .normal), for: .normal)
        tappedButton.setTitle("", for: .normal)
        
        // Move the empty space index
        emptySpaceIndex = tappedIndex
        checkWinCondition()
    }
    
    func checkWinCondition() {
            // Loop through the buttons and check if each one is in its correct position
            for i in 0..<buttons.count {
                let button = buttons[i]
                if button.title(for: .normal) != "\(i + 1)" && (i != 8 || button.title(for: .normal) != "") {
                    return // If any button is out of order, return without doing anything
                }
            }
            
            // If the loop completes, the puzzle is solved
            let alert = UIAlertController(title: "Congratulations!", message: "You solved the puzzle!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
}
