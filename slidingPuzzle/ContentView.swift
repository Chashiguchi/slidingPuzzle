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
        VStack {
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
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
        
        for i in 0..<gridSize * gridSize {
            let row = i / gridSize
            let col = i % gridSize
            let button = UIButton(type: .system)
            button.frame = CGRect(x: CGFloat(col) * (buttonSize + padding), y: CGFloat(row) * (buttonSize + padding), width: buttonSize, height: buttonSize)
            
            // Set up button actions
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
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
    }
}
