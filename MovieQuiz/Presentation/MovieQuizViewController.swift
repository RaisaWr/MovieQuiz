
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    private var questionFactory: QuestionFactoryProtocol?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let statisticService: StatisticServiceProtocol = StatisticService()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory

        imageView.layer.cornerRadius = 20
        self.questionFactory?.requestNextQuestion()
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        show(quiz: viewModel)
    }

    // MARK: - Actions

    @IBAction private func yesButton(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }

        let correctAnswer = true
        showAnswerResult(is: correctAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButton(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }

        let correctAnswer = false
        showAnswerResult(is: correctAnswer == currentQuestion.correctAnswer)
    }

    // MARK: - Outlets

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!

    // MARK: - Properties

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?

    // MARK: - Private Methods

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            text: model.text,
            counter: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )

        return questionStep
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.text
        counterLabel.text = step.counter
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    private func showAnswerResult(is correct: Bool) {
        if correct {
            correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = correct
            ? UIColor.ypGreenIOS.cgColor
            : UIColor.ypRedIOS.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {

            statisticService.store(
                correct: correctAnswers,
                total: questionsAmount
            )

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"

            let bestGameDate = dateFormatter.string(
                from: statisticService.bestGame.date
            )

            let alertModel = AlertModel(
                title: "Этот раунд окончен",
                message: """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(bestGameDate))
                Средняя точность: \(String(format: "%.1f", statisticService.totalAccuracy))%
                """,
                buttonText: "Сыграть еще раз"
            ) { [weak self] in
                guard let self = self else { return }

                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }

            alertPresenter.show(alertModel: alertModel)

        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
}

