//
//  NLTagExtension.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 18/05/23.
//

import Foundation
import NaturalLanguage

extension NLTag {
    static var withColor = NLTag("with_color")
    static var withoutColor = NLTag("without_color")
    static var color = NLTag("Color")
    
    static var black = NLTag("BLACK")
    static var orange = NLTag("ORANGE")
    static var white = NLTag("WHITE")
    static var red = NLTag("RED")
    static var magenta = NLTag("MAGENTA")
    static var pink = NLTag("PINK")
    static var purple = NLTag("PURPLE")
    static var yellow = NLTag("YELLOW")
    static var violet = NLTag("VIOLET")
    static var green = NLTag("GREEN")
    static var cyan = NLTag("CYAN")
    static var blue = NLTag("BLUE")
    static var gray = NLTag("GRAY")
}
