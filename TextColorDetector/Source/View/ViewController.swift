//
//  ViewController.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 18/05/23.
//

import UIKit
import NaturalLanguage
import Speech

class ViewController: UIViewController {
    var screen: MainView?
    var viewModel: ViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detect Colors"
        self.screen = MainView()
        self.viewModel = ViewModel()
        self.view = screen
        navigationItem.rightBarButtonItem = UIBarButtonItem (
            title: "Detect",
            style: .done, target: self,
            action: #selector(detectarCores)
        )
    }

    @objc func detectarCores() {
        view.endEditing(true)
        screen?.clearColors()
        if screen?.inputTextField.text == "" {
            let warning = Warning (
                title: "No entry entered!",
                message: "Enter some text with the color of the item you want to match."
            )
            generatAlert(warning: warning)
            return
        }
        
        let result = viewModel?.executeDetection(inputText: (screen?.inputTextField.text)!)
        
        switch result {
        case .failure(let error):
            let detectionWarning = Warning(
                title: error.description,
                message: error.errorDescription!
            )
            generatAlert(warning: detectionWarning)

        case .success(let colorsList):
            screen?.generateColors(colorsList)
            
        case .none:
            fatalError("Fail in detection return!")
        }
        
    }
    
    // Função que gera um alerta
    private func generatAlert(warning: Warning) {
        let alert = UIAlertController(title: warning.title,
                                      message: warning.message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
