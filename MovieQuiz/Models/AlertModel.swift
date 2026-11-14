//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Raisa Wr on 14.11.2026.
//

import Foundation
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)
}
