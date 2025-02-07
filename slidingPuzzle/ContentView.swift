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
            .edgesIgnoringSafeArea(.all)
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
    }
}

class ViewController: UIViewController {
    var buttons: [UIButton] = []
    var emptySpaceIndex = 8  // 0-indexed position for 3x3 grid (empty space at last)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the game board
        setupPuzzle()
        resetButton()
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
    
    func resetButton() {
        // Create a reset button
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        
        // Calculate the position of the reset button based on the grid's size
        let gridHeight = CGFloat(3 * 100 + 2 * 10) // 3x3 grid, 100 for button size, 10 for padding between buttons
        let totalHeight = gridHeight + 10 // Add some space between the grid and the reset button
        let buttonY = self.view.frame.height - totalHeight + 50 // Position it below the grid (adjust 60 for spacing)
        
        resetButton.frame = CGRect(x: (self.view.frame.width - 100) / 2, y: buttonY, width: 100, height: 50)
        resetButton.addTarget(self, action: #selector(resetPuzzle), for: .touchUpInside)
        
        // Add the reset button to the view
        self.view.addSubview(resetButton)
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
    
    @objc func resetPuzzle() {
        var startingNumbers: [Int]
        //generate a solvable puzzle
        repeat {
            startingNumbers = (1..<9).shuffled() + [0] // shuffle numbers 1-8, 0 = empty space
        } while !isSolvable(startingNumbers)
        emptySpaceIndex = startingNumbers.firstIndex(of: 0) ?? 8
        for i in 0..<buttons.count {
            let button = buttons[i]
            if startingNumbers[i] != 0 {
                button.setTitle("\(startingNumbers[i])", for: .normal)
            } else {
                button.setTitle("", for: .normal)
            }
        }
    }
    
    func swapButtons(_ tappedIndex: Int) {  // Update empty space index
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
            // The last button should be blank until solved
            if i == 8 {
                if button.title(for: .normal) != "" {
                    return  // If it's not blank, the puzzle isn't solved
                }
            } else if button.title(for: .normal) != "\(i + 1)" {
                return  // Any other button out of place means the puzzle isn't solved
            }
        }
        buttons[emptySpaceIndex].setTitle("9", for: .normal)//replaces the blank space with 9
        // If the loop completes, the puzzle is solved
        let alert = UIAlertController(title: "Congratulations!", message: "You solved the puzzle!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default));             present(alert, animated: true, completion: nil)
    }
    
    func isSolvable(_ tiles: [Int]) -> Bool {
        var inversionCount = 0
        let numbers = tiles.filter { $0 != 0}
        
        for i in 0..<numbers.count {
            for j in i+1..<numbers.count {
                if numbers[i] > numbers[j] {
                    inversionCount += 1
                }
            }
        }
        return inversionCount % 2 == 0 // Solvable if even
    }
}
