//
//  SetViewProtocol.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 18/05/23.
//

import Foundation

public protocol SettingViews {
    func setupSubviews()
    func setupConstraints()
}

extension SettingViews {
    func buildLayoutView() {
        setupSubviews()
        setupConstraints()
    }
}
