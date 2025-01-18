//
//  RecordingView.swift
//  Mixed-Ability-Artwork
//
//  Created by Ritesh Kanchi on 7/22/24.
//

import SwiftUI

var audioRecorder = AudioRecorder()
var audioPlayer = AudioPlayer()

struct RecordingView: View {
    
    @Binding var name: String
    @Binding var usingRecording: Bool
    @Binding var sheetTab: Int
    @Binding var loadingNewDescription: Bool
    
    @Binding var currentDescriptive: String
    @Binding var currentCreative: String
    @Binding var currentQuestions: String
    @Binding var imageDescription: ImageDescription
    
    @Binding var regenerating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Text(regenerating ? "Please wait for the regeneration to finish to add a voice recording." : "Pair your artwork with a voice recording!")
            }
            if !regenerating {
                RecorderWidget(imageDescription: imageDescription)
                Divider()
                    .padding(.vertical)
                Transcript()
                Divider()
                    .padding(.vertical)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Update Description")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(!usingRecording ? "Do you want to use your recording to improve or inform your provided description?" : "You are currently using the recording to update your description.")
                    if !usingRecording {
                        Button("Use recording") {
                            withAnimation {
                                loadingNewDescription = true
                                sheetTab = 0
                                addMessage(threadId: imageDescription.id)
                                usingRecording = true
                            }
                        }
                        .buttonStyle(FullWidthWhiteButtonStyle())
                        Text("Future recordings will result in updated descriptions as well.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                }
            }
        }
        .padding(.horizontal)
        .padding(5)
    }
    
    private func addMessage(threadId: String) {
        OpenAIHelpers.shared.addMessage(threadId: threadId, message: transcriptionPrompt + audioRecorder.transcription) {
            runThread(threadId: threadId)
        } failure: { error in
            print("Failed to add message: \(error.localizedDescription)")
        }
    }

    private func runThread(threadId: String) {
        OpenAIHelpers.shared.runThread(threadId: threadId) { runId in
            OpenAIHelpers.shared.pollForResult(threadId: threadId, runId: runId, messages: { _ in
                getMessages(threadId: threadId)
            }, failure: { error in
                print("Failed to poll for result: \(error.localizedDescription)")
            })
        } failure: { error in
            print("Failed to run thread: \(error.localizedDescription)")
        }
    }

    private func getMessages(threadId: String) {
        OpenAIHelpers.shared.getMessages(threadId: threadId) { message in
            requestCompleted(description: message)
        } failure: { error in
            print("Failed to get messages: \(error.localizedDescription)")
        }
    }
    
    private func requestCompleted(description: String) {
        withAnimation {
            // Print the raw response for debugging
            //print("Raw response: \(description)")
            
            print("NEW DESCRIPTION")
            print(description)

            // Split the description into components
            let components = description.components(separatedBy: "%%%")
            guard components.count == 4 else {
                fatalError("Description content format is incorrect.")
            }
            
            // Extract and format each component
            name = components[0].replacingOccurrences(of: "Title: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            currentDescriptive = components[1].replacingOccurrences(of: "Descriptive Description: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            currentCreative = components[2].replacingOccurrences(of: "Creative Description: ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            currentQuestions = components[3].trimmingCharacters(in: .whitespacesAndNewlines)
            
            imageDescription.name = name
            imageDescription.descriptiveDescription = currentDescriptive
            imageDescription.creativeDescription = currentCreative
            imageDescription.questions = currentQuestions
            ImageManager.shared.save(item: imageDescription)
            
            loadingNewDescription = false
        }
    }
}

struct Transcript: View {
    @State private var showTranscript = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                withAnimation {
                    showTranscript.toggle()
                }
            }) {
                HStack {
                    Text("Transcript")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: showTranscript ? "chevron.up" : "chevron.down")
                        .imageScale(.medium)
                        .foregroundColor(.gray)
                }
            }
            .accessibilityAddTraits(.isToggle)
            .accessibilityRepresentation(representation: {
                Toggle(isOn: $showTranscript) {
                    Text("Show Audio Transcription")
                }
            })
            if showTranscript {
                
                Text(audioRecorder.transcription.isEmpty ? "No transcription yet" : audioRecorder.transcription)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(10)
                    .multilineTextAlignment(.leading)
                
                
            }
        }
        .onReceive(audioRecorder.$transcription, perform: { isEmpty in
            showTranscript.toggle()
        })
    }
}

enum RecorderStates {
    case none, recording, existing, playing, stopped
}

struct RecorderWidget: View {
    
    @State private var currentState: RecorderStates = .none
    @State private var filename: String = ""
    @State private var accessibilityLabel: String = "Start recording"
    
    var imageDescription: ImageDescription
    
    private let root = "Mixed-Ability-Artwork/Descriptions"
    
    
    init(imageDescription: ImageDescription) {
        self.imageDescription = imageDescription
        _filename = .init(initialValue: imageDescription.id)
        ImageManager.shared.createDirIfNeeded(for: filename)
        
        // Reinitialize audioRecorder and audioPlayer for each view instance
        audioRecorder = AudioRecorder()
        audioPlayer = AudioPlayer()
        
        if recordingExists(filename: filename) {
            currentState = .existing
            accessibilityLabel = "Play recording"
            let recordingURL = audioRecorder.getFileURL(filename: filename)
            audioRecorder.transcribeAudio(url: recordingURL)
        }
        else{
            currentState = .none
        }
    }
    
    var body: some View {
        HStack {
            //            if currentState == .none {
            //                Text("Tap to start recording")
            //                    .fontWeight(.semibold)
            //                    .padding(.leading, 10)
            //            } else if currentState == .recording {
            //                Text("Recording...")
            //                    .font(.system(size: 32, weight: .regular, design: .default))
            //                    .padding(.leading, 10)
            //                    .foregroundColor(.red)
            //            } else if !audioRecorder.isRecording, currentState == .existing {
            //                Text("Play Recording")
            //                    .fontWeight(.semibold)
            //                    .padding(.leading, 10)
            //                    .padding(.trailing, 15)
            //            }
            //            else if audioPlayer.isPlaying {
            //                Text("Playing Recording...")
            //                    .fontWeight(.semibold)
            //                    .padding(.leading, 10)
            //                    .padding(.trailing, 15)
            //            }
            Text(currentState == .none ? "Tap to start recording" : currentState == .recording ? "Recording..." : (!audioRecorder.isRecording && currentState == .existing) ? "Play recording" : audioPlayer.isPlaying ? "Playing Recording..." : "Tap to start recording")
                .fontWeight(.semibold)
                .padding(.leading, 10)
                .foregroundColor(currentState == .recording ? .red : .white)
            
            Spacer()
            Button(action: {
                withAnimation {
                    let recordingURL = audioRecorder.getFileURL(filename: filename)
                    if currentState == .none {
                        accessibilityLabel = "Stop recording"
                        audioRecorder.startRecording(fileName: imageDescription.id)
                        if audioRecorder.isRecording {
                            currentState = .recording
                        }
                    } else if currentState == .recording {
                        accessibilityLabel = "Play recording"
                        audioRecorder.stopRecording()
                        currentState = .existing
                        audioRecorder.transcribeAudio(url: recordingURL)
                    } else if currentState == .existing {
                        accessibilityLabel = "Stop playback"
                        audioPlayer.playAudio(url: recordingURL)
                        if audioPlayer.isPlaying {
                            currentState = .playing
                        }
                    } else if currentState == .playing, audioPlayer.isPlaying{
                        currentState = .existing
                        audioPlayer.stopAudio()
                    } else if currentState == .playing, !audioPlayer.isPlaying{
                        currentState = .existing
                    }
                    else {
                        currentState = .none
                    }
                }
            })  {
                ZStack {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 48, height: 48)
                        if currentState == .recording || currentState == .none {
                            Rectangle()
                                .fill(.red)
                                .clipShape(.rect(cornerRadius: currentState == .none ? 100 : 5, style: .continuous))
                                .frame(width: currentState == .none ? 40 : 23, height: currentState == .none ? 40 : 23)
                        } else {
                            Image(systemName: currentState == .playing ? "stop.fill" : "play.fill")
                                .imageScale(.large)
                                .foregroundStyle(.red)
                        }
                        
                    }
                }
            }
            .accessibilityLabel(accessibilityLabel)
            .onReceive(audioPlayer.$isPlaying, perform: { isPlaying in
                if !isPlaying, recordingExists(filename: filename) {
                    currentState = .existing
                    accessibilityLabel = "Play recording"
                }
                if !isPlaying, !recordingExists(filename: filename) {
                    currentState = .none
                    accessibilityLabel = "Start recording"
                }
            })
            if currentState == .existing || currentState == .playing  {
                Button(action: {
                    withAnimation {
                        deleteRecordingFile(filename: filename)
                        audioRecorder.transcription = ""
                        currentState = .none
                        accessibilityLabel = "Start recording"
                    }
                })  {
                    ZStack {
                        ZStack {
                            Circle()
                                .strokeBorder(.white, lineWidth: 3)
                                .frame(width: 48, height: 48)
                            Image(systemName: "arrow.counterclockwise")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .accessibilityLabel("Re-record voice recording")
            }
        }
        .foregroundStyle(.white)
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12, style: .continuous))
        .padding(.top)
    }
    
    func recordingExists(filename: String) -> Bool {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(root)/\(filename)" + "/")
        let filePath = dir.appendingPathComponent("recording.m4a").path
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    func deleteRecordingFile(filename: String) {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(root)/\(filename)" + "/")
        let filePath = dir.appendingPathComponent("recording.m4a").path
        
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                print("Error deleting recording file: \(error.localizedDescription)")
            }
        } else {
            print("Recording file does not exist.")
        }
    }
    
}
//
//#Preview {
//    //    RecorderWidget()
////    RecordingView(imageDescription: SampleData.sampleImageDescriptions.first!)
//}
