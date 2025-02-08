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
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

class ViewController: UIViewController {
    var buttons: [UIButton] = []
    var emptySpaceIndex = 8 // Empty space at last index of a 3x3 grid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray //background color
        setupTitle()  // Add the title
        setupPuzzle()
        resetButton()
    }
    
    func setupPuzzle() {
        let gridSize = 3 // 3x3 grid
        let buttonSize: CGFloat = 100.0
        let padding: CGFloat = 10.0
        let startingNumbers = (1..<9).shuffled() + [0] // Numbers 1-8 shuffled, 0 is the empty space
        
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
            
            button.tag = i
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            button.backgroundColor = UIColor.systemTeal // Button background color
            button.layer.cornerRadius = 10 // Rounded corners
            button.layer.masksToBounds = true
            
            if startingNumbers[i] != 0 {
                button.setTitle("\(startingNumbers[i])", for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)  // White text for numbers
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24) // Larger, bold font
            } else {
                button.setTitle("", for: .normal) // Empty space has no title
            }
            
            self.view.addSubview(button)
            buttons.append(button)
        }
    }
    
    func setupTitle() {
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = "Sliding Puzzle"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)  // Adjust font size as needed
        titleLabel.textColor = UIColor.black  // Title text color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the view
        view.addSubview(titleLabel)
        
        // Set constraints to position the title at the top
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func resetButton() {
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = UIColor.systemBlue
        resetButton.layer.cornerRadius = 12 // Rounded corners
        resetButton.layer.shadowOpacity = 0.3 // Add subtle shadow
        resetButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        resetButton.layer.shadowRadius = 4
        
        let gridHeight = CGFloat(3 * 100 + 2 * 10) // Height of the grid
        let buttonY = self.view.frame.height - gridHeight + 60
        
        resetButton.frame = CGRect(x: (self.view.frame.width - 150) / 2, y: buttonY, width: 150, height: 50)
        resetButton.addTarget(self, action: #selector(resetPuzzle), for: .touchUpInside)
        
        self.view.addSubview(resetButton)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let tappedIndex = sender.tag
        let emptyRow = emptySpaceIndex / 3
        let emptyCol = emptySpaceIndex % 3
        let tappedRow = tappedIndex / 3
        let tappedCol = tappedIndex % 3
        
        if (abs(emptyRow - tappedRow) == 1 && emptyCol == tappedCol) || (abs(emptyCol - tappedCol) == 1 && emptyRow == tappedRow) {
            swapButtons(tappedIndex)
        }
    }
    
    @objc func resetPuzzle() {
        var startingNumbers: [Int]
        repeat {
            startingNumbers = (1..<9).shuffled() + [0]
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
    
    func swapButtons(_ tappedIndex: Int) {
        let tappedButton = buttons[tappedIndex]
        buttons[emptySpaceIndex].setTitle(tappedButton.title(for: .normal), for: .normal)
        tappedButton.setTitle("", for: .normal)
        
        emptySpaceIndex = tappedIndex
        checkWinCondition()
    }
    
    func checkWinCondition() {
        for i in 0..<buttons.count {
            let button = buttons[i]
            if i == 8 {
                if button.title(for: .normal) != "" {
                    return
                }
            } else if button.title(for: .normal) != "\(i + 1)" {
                return
            }
        }
        buttons[emptySpaceIndex].setTitle("9", for: .normal)
        
        let alert = UIAlertController(title: "Congratulations!", message: "You solved the puzzle!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func isSolvable(_ tiles: [Int]) -> Bool {
        var inversionCount = 0
        let numbers = tiles.filter { $0 != 0 }
        
        for i in 0..<numbers.count {
            for j in i+1..<numbers.count {
                if numbers[i] > numbers[j] {
                    inversionCount += 1
                }
            }
        }
        return inversionCount % 2 == 0
    }
}
