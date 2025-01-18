import Foundation
import AVFoundation
import Speech

class AudioRecorder: NSObject, AVAudioRecorderDelegate, ObservableObject {
    @Published var recordingURL: URL?
    @Published var isRecording: Bool = false
    @Published var transcription: String = ""
    var audioRecorder: AVAudioRecorder?
    private let root = "Mixed-Ability-Artwork/Descriptions"

    override init() {
        super.init()
        requestSpeechRecognitionAuthorization()
    }

    func requestSpeechRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied:
                print("Speech recognition authorization denied")
            case .restricted:
                print("Speech recognition restricted")
            case .notDetermined:
                print("Speech recognition not determined")
            @unknown default:
                fatalError()
            }
        }
    }

    func startRecording(fileName: String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recordingURL = getFileURL(filename: fileName)
            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
            print("Recording started!")
        } catch {
            print("Failed to set up audio session and recorder: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        print("Recording ended!")
        
        if let url = recordingURL {
            transcribeAudio(url: url)
        }
    }

    func getFileURL(filename: String) -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0]
        return documentDirectory.appendingPathComponent("\(root)/\(filename)/recording.m4a")
    }

    func transcribeAudio(url: URL) {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            print("Speech recognizer is not available")
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcription = result.bestTranscription.formattedString
                } else if let error = error {
                    print("Transcription error: \(error.localizedDescription)")
                }
            }
        }
    }
}
