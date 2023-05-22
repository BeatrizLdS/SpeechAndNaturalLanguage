//
//  Detector.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 18/05/23.
//

import Foundation
import NaturalLanguage
import CoreML

class Detector {
    let inputText: String
    
    init(inputText: String) {
        self.inputText = inputText
    }
    
    func detect() -> Result<[NLTag], DectectorErrors> {
        // Check if inputText is in English
        guard isEnglish(inputText) else {
            return .failure(DectectorErrors.notInEnglish)
        }
        
        guard haveColors(inputText) else {
            return .failure(DectectorErrors.noColors)
        }
        
        let wordsInString = inputText.components(separatedBy: " ")
        var colorsName = wordsInString[0]
        if wordsInString.count > 1 {
            if let foundColors = findColors(inputText) {
                colorsName = foundColors
            } else {
                return .failure(.noColorFound)
            }
        }
        
        let colorsFound = determineColors(colorsName)
        return .success(colorsFound)
    }
    
    private func isEnglish(_ string: String) -> Bool {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(string)
        for (language, _) in recognizer.languageHypotheses(withMaximum: 5) {
            if language == .english {
                return true
            }
        }
        return false
    }
    
    private func haveColors(_ string: String) -> Bool {
        var haveColors = false
        let stringRange = string.startIndex..<string.endIndex
        do {
            let mlmodel = try HaveColor5(configuration: MLModelConfiguration())
            let customModel = try NLModel(mlModel: mlmodel.model)
            let customTagScheme = NLTagScheme("Colors")
            
            let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass, customTagScheme])
            tagger.string = string
            tagger.setModels([customModel], forTagScheme: customTagScheme)
            
            tagger.enumerateTags(
                in: stringRange,
                unit: .sentence,
                scheme: customTagScheme,
                options: [.omitWhitespace, .omitPunctuation, .joinNames]
            ) { tag, tokenRange  in
                if let tag = tag, tag == .withColor{
                    haveColors = true
                }
                return true
            }
            
        } catch {
            fatalError(error.localizedDescription)
        }
        return haveColors
    }
    
    func findColors(_ string: String) -> String? {
        var colors: String? = nil
        do {
            let config = MLModelConfiguration()
            let mlmodel = try FindColor3Copy(configuration: config).model
            let customModel = try NLModel(mlModel: mlmodel)
            let customTagScheme = NLTagScheme("Colors")
            
            let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass, customTagScheme])
            tagger.string = string
            tagger.setModels([customModel], forTagScheme: customTagScheme)
            
            let stringRange = string.startIndex..<string.endIndex
            tagger.string = string
            tagger.enumerateTags(
                in: stringRange,
                unit: .word,
                scheme: customTagScheme,
                options: .omitWhitespace
            ) { tag, tokenRange  in
                if let tag = tag, tag == .color {
                    if colors == nil{
                        colors = ""
                    }
                    colors!.append("\(string[tokenRange]) ")
                }
                return true
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        return colors
    }
    
    func determineColors(_ string: String) -> [NLTag] {
        let config = MLModelConfiguration()
        let mlmodel = try? ColorsTaggingTest(configuration: config).model
        let customModel = try? NLModel(mlModel: mlmodel!)
        let customTagScheme = NLTagScheme("Colors")
        
        let tagger = NLTagger(tagSchemes: [.nameTypeOrLexicalClass, customTagScheme])
        tagger.string = string
        tagger.setModels([customModel!], forTagScheme: customTagScheme)
        
        var colorsTag: [NLTag] = []
        let stringRange = string.startIndex..<string.endIndex
        tagger.string = string
        tagger.enumerateTags(
            in: stringRange,
            unit: .word,
            scheme: customTagScheme,
            options: .omitWhitespace
        ) { tag, tokenRange  in
            if let tag = tag{
                colorsTag.append(tag)
            }
            return true
        }
        return colorsTag
    }
}
