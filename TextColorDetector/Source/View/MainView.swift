//
//  InputView.swift
//  TextColorDetector
//
//  Created by Beatriz Leonel da Silva on 18/05/23.
//

import UIKit
import Speech

class MainView: UIView {
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))!
    private var speechRecognitionBufferRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionURLRequest: SFSpeechURLRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var status:SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    var inputTextLabel: UILabel = {
        var label = UILabel()
        label.text = "To detect:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .natural
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var inputTextField: UITextField = {
        var textField = UITextField()
        textField.placeholder = "What do you want to detect"
        textField.textAlignment = .center
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        button.setTitle("Record", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    } ()
    
    var colorsContainer: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.backgroundColor = .systemGray5
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    } ()
    
    var colorsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.backgroundColor = .clear
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        buildLayoutView()
        configKeyBoardTapGesture()
        recordButton.addTarget(self, action: #selector(speechTranscribing), for: .touchUpInside)
//        askPermission()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func askPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    self.status = .authorized
                default:
                    self.status = .notDetermined
                }
            }
        }
    }
    
    func configKeyBoardTapGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing))
        self.addGestureRecognizer(gesture)
    }
    
    func generateColorView(color: UIColor) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 50
        return view
    }
    
    func clearColors() {
        for subview in colorsStack.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
    
    func generateColors(_ colorsList: [UIColor]) {
        for color in colorsList {
            let colorView = generateColorView(color: color)
            colorView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            colorView.widthAnchor.constraint(equalToConstant: 100).isActive = true

            colorsStack.addArrangedSubview(colorView)
        }
    }
}

// MARK: Speech
extension MainView {
    
    @objc func speechTranscribing() {
        if audioEngine.isRunning {
            audioEngine.stop()
            speechRecognitionBufferRequest?.endAudio()
            recordButton.setTitle("Record", for: .normal)
        } else {
            startSyncSession()
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    
    func startSyncSession() {
        do {
            // Verifica se já tem um SFSpeechRecognitionTask rodando, se sim cancela e restarta ele
            if let recognitionTask = speechRecognitionTask {
                recognitionTask.cancel()
                self.speechRecognitionTask = nil
            }
            
            // Configura o AVAudioSession para captura de áudio
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                AVAudioSession.Category.record ,
                mode: .default
            )
            
            // Cria objeto que ira fazer a solicitação de reconhecimento de algum áudio
            speechRecognitionBufferRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = speechRecognitionBufferRequest else {
                fatalError("SFSpeechAudioBufferRecognitionRequest object creation failed")
            }
            
            let inputNode = audioEngine.inputNode
            
            recognitionRequest.shouldReportPartialResults = true
            
            speechRecognitionTask = speechRecognizer.recognitionTask(
                with: recognitionRequest) { result, error in
                    
                    var finished = false
                    
                    if let result = result {
                        self.inputTextField.text = result.bestTranscription.formattedString
                        finished = result.isFinal
                    }
                    
                    if error != nil || finished {
                        self.audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        
                        self.speechRecognitionBufferRequest = nil
                        self.speechRecognitionTask = nil
                        
                    }
                }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
                (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.speechRecognitionBufferRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
}


extension MainView: SettingViews {
    func setupSubviews() {
        self.addSubview(inputTextLabel)
        self.addSubview(recordButton)
        self.addSubview(inputTextField)
        self.addSubview(colorsContainer)
        colorsContainer.addSubview(colorsStack)
    }
    
    func setupConstraints() {
        let inputTextLabelConstraints = [
            inputTextLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            inputTextLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 25),
            inputTextLabel.heightAnchor.constraint(equalToConstant: 50)
        ]
        let recordButtonContraints = [
            recordButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            recordButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 25),
            recordButton.heightAnchor.constraint(equalToConstant: 40),
            recordButton.centerYAnchor.constraint(equalTo: inputTextLabel.centerYAnchor),
            recordButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2)
        ]
        let inputTextFieldConstraints = [
            inputTextField.topAnchor.constraint(equalTo: self.inputTextLabel.bottomAnchor, constant: 10),
            inputTextField.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            inputTextField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            inputTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        let colorsContainerConstraints = [
            colorsContainer.topAnchor.constraint(equalTo: self.inputTextField.bottomAnchor, constant: 50),
            colorsContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            colorsContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            colorsContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        let colorsStackConstraints = [
            colorsStack.topAnchor.constraint(equalTo: self.colorsContainer.topAnchor, constant: 20),
            colorsStack.bottomAnchor.constraint(equalTo: self.colorsContainer.bottomAnchor, constant: 20),
            colorsStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            colorsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            
        ]
        NSLayoutConstraint.activate(inputTextLabelConstraints)
        NSLayoutConstraint.activate(recordButtonContraints)
        NSLayoutConstraint.activate(inputTextFieldConstraints)
        NSLayoutConstraint.activate(colorsContainerConstraints)
        NSLayoutConstraint.activate(colorsStackConstraints)
    }
    
}
