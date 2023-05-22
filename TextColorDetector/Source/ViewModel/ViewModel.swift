//
//  ViewModel.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 18/05/23.
//

import Foundation
import UIKit
import NaturalLanguage

class ViewModel {
    
    var colorsList: [NLTag] = []
    
    func executeDetection(inputText: String) -> Result<[UIColor], DectectorErrors> {
        var UIcolors: [UIColor] = []
        let detector = Detector(inputText: inputText)
        let result = detector.detect()
        switch result {
        case .success(let data):
            self.colorsList = data
            for color in colorsList {
                switch color {
                case .black:
                    UIcolors.append(.black)
                case .blue:
                    UIcolors.append(.blue)
                case .cyan:
                    UIcolors.append(.cyan)
                case .gray:
                    UIcolors.append(.gray)
                case .green:
                    UIcolors.append(.green)
                case .magenta:
                    UIcolors.append(.magenta)
                case .orange:
                    UIcolors.append(.orange)
                case .pink:
                    UIcolors.append(.pink)
                case .purple:
                    UIcolors.append(.purple)
                case .red:
                    UIcolors.append(.red)
                case .violet:
                    UIcolors.append(.violet)
                case .white:
                    UIcolors.append(.white)
                case .yellow:
                    UIcolors.append(.yellow)
                default:
                    fatalError("No one of colors!")
                }
            }
            return .success(UIcolors)
        case .failure(let error):
            return .failure(error)
        }
    }
}
