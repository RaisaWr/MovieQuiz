//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Raisa Wr on 14.11.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

