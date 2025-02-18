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
        // Embed the UIKit-based ViewController into the SwiftUI View
        PuzzleViewControllerWrapper()
        // Makes the PuzzleViewControllerWrapper take up the entire screen
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
// This struct wraps a UIKit-based ViewController to be used in SwiftUI
struct PuzzleViewControllerWrapper: UIViewControllerRepresentable {
    // This method creates and returns an instance of the ViewController
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    // This method is used to update the view controller when SwiftUI state changes
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}
    //defines a custom class that inherits from UIViewController, allowing it to manage the view and handle interactions for the sliding puzzle game screen.
class ViewController: UIViewController {
    var buttons: [UIButton] = []
    var emptySpaceIndex = 8 // Empty space at last index of a 3x3 grid
    // Called when the view is loaded into memory
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
            let button = UIButton(type: .system) // Create a button for each grid cell
            // Calculate the X and Y positions based on the button size and padding
            let x = startX + CGFloat(col) * (buttonSize + padding)
            let y = startY + CGFloat(row) * (buttonSize + padding)
            button.frame = CGRect(x: x, y: y, width: buttonSize, height: buttonSize)
            // Assign a unique tag to each button for identification
            button.tag = i
            // Add action to handle button taps
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            button.backgroundColor = UIColor.systemTeal // Button background color
            button.layer.cornerRadius = 10 // Rounded corners
            button.layer.masksToBounds = true // Ensure the corners are properly clipped
            if startingNumbers[i] != 0 {
                button.setTitle("\(startingNumbers[i])", for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)  // White text for numbers
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24) // Larger, bold font
            } else {
                button.setTitle("", for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            }
            // Add the button to the view and keep a reference in the buttons array
            self.view.addSubview(button)
            buttons.append(button)
        }
    }
    
    func setupTitle() {
        // Create a UILabel to display the title
        let titleLabel = UILabel()
        titleLabel.text = "Sliding Puzzle"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = UIColor.black
        // Disable the automatic constraint translation for this label
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
        // Create the "Reset" button
        let resetButton = UIButton(type: .system)
        // Set the title of the button to "Reset" for the normal state
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = UIColor.systemBlue
        resetButton.layer.cornerRadius = 12 // Rounded corners
        // Add a subtle shadow to the button for a lifted effect
        resetButton.layer.shadowOpacity = 0.3 // Add subtle shadow
        resetButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        resetButton.layer.shadowRadius = 4
        // Calculate the Y position for the button, ensuring it is placed below the puzzle grid
        let gridHeight = CGFloat(3 * 100 + 2 * 10) // Height of the grid
        let buttonY = self.view.frame.height - gridHeight + 60
        // Set the button's frame (size and position)
        resetButton.frame = CGRect(x: (self.view.frame.width - 150) / 2, y: buttonY, width: 150, height: 50)
        resetButton.addTarget(self, action: #selector(resetPuzzle), for: .touchUpInside)
        // Add the button to the view
        self.view.addSubview(resetButton)
    }
    
    //The @objc attribute exposes a Swift method to the Objective-C runtime, making it accessible for selectors and other Objective-C-based systems.
    @objc func buttonTapped(_ sender: UIButton) {
        let tappedIndex = sender.tag
        // Calculate the row and column of the empty space
        let emptyRow = emptySpaceIndex / 3
        let emptyCol = emptySpaceIndex % 3
        // Calculate the row and column of the tapped button
        let tappedRow = tappedIndex / 3
        let tappedCol = tappedIndex % 3
        // Check if the tapped button is adjacent to the empty space
        if (abs(emptyRow - tappedRow) == 1 && emptyCol == tappedCol) || (abs(emptyCol - tappedCol) == 1 && emptyRow == tappedRow) {
            // If adjacent, swap the tapped button with the empty space
            swapButtons(tappedIndex)
        }
    }
    
    @objc func resetPuzzle() {
        var startingNumbers: [Int]
        // Generate a random configuration for the puzzle, ensuring that it's solvable
        repeat {
            startingNumbers = (1..<9).shuffled() + [0]
        } while !isSolvable(startingNumbers)
        emptySpaceIndex = startingNumbers.firstIndex(of: 0) ?? 8
        // Update the titles of each button based on the shuffled starting configuration
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
        //get button that was tapped
        let tappedButton = buttons[tappedIndex]
        // Swap the title of the tapped button with the empty space button
        buttons[emptySpaceIndex].setTitle(tappedButton.title(for: .normal), for: .normal)
        //move number to the empty space
        tappedButton.setTitle("", for: .normal)
        // Update the empty space index to the new location of the empty space
        emptySpaceIndex = tappedIndex
        // After swapping, check if the puzzle has been solved
        checkWinCondition()
    }
    
    func checkWinCondition() {
        for i in 0..<buttons.count {
            let button = buttons[i]
            // Check if the current button is the last button (empty space)
            if i == 8 {
                if button.title(for: .normal) != "" {
                    return // If the last button is not empty, the puzzle is not solved
                }
            } else if button.title(for: .normal) != "\(i + 1)" {
                return // If any button is not in its correct position, the puzzle is not solved
            }
        }
        buttons[emptySpaceIndex].setTitle("9", for: .normal)
        let alert = UIAlertController(title: "Congratulations!", message: "You solved the puzzle!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func isSolvable(_ tiles: [Int]) -> Bool {
        var inversionCount = 0
        // Remove the empty space (represented by 0) from the puzzle array to check only the numbers
        let numbers = tiles.filter { $0 != 0 }
        for i in 0..<numbers.count {
            for j in i+1..<numbers.count {
                // Check if a number appears before a smaller number (inversion)
                if numbers[i] > numbers[j] {
                    inversionCount += 1 // If an inversion is found, increment the inversion count
                }
            }
        }
        // A puzzle is solvable if the number of inversions is even and not when inversions are odd
        return inversionCount % 2 == 0
    }
}
