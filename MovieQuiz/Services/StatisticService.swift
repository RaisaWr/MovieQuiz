//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Raisa Wr on 15.11.2026.
//


import Foundation

final class StatisticService: StatisticServiceProtocol {
  
    // MARK: - Storage

    private let storage: UserDefaults = .standard

    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalCorrectAnswers
        case totalQuestionsAsked
    }

    // MARK: - Games Count
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    // MARK: - Best Game

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()

            return GameResult(
                correct: correct,
                total: total,
                date: date
            )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    // MARK: - Intermediate Properties

    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }

    // MARK: - Total Accuracy

    var totalAccuracy: Double {
        guard totalQuestionsAsked > 0 else {
            return 0
        }

        return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
    }

    // MARK: - Store

    func store(correct count: Int, total amount: Int) {

        gamesCount += 1
        totalCorrectAnswers += count
        totalQuestionsAsked += amount

        let currentGame = GameResult(
            correct: count,
            total: amount,
            date: Date()
        )

        if gamesCount == 1 || currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
    }
}
