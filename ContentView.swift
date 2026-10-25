import SwiftUI
import Speech
import AVFoundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let fromNokshi: Bool
}

struct ContentView: View {
    @State private var input = ""
    @State private var messages = [
        ChatMessage(text: "হেই বেবি 💜 আমি নকশী। কী করতে সাহায্য করব?", fromNokshi: true)
    ]
    @StateObject private var speech = SpeechManager()

    private let bg = Color(red: 0.035, green: 0.025, blue: 0.09)
    private let neon = Color(red: 0.30, green: 0.88, blue: 1.0)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [bg, Color(red: 0.10, green: 0.035, blue: 0.20), bg],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 5) {
                    Text("NOKSHI AI")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(neon)
                        .shadow(color: neon.opacity(0.7), radius: 14)
                    Text("YOUR PERSONAL BENGALI COMPANION")
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.65))
                    Circle()
                        .fill(speech.isListening ? Color.green : neon)
                        .frame(width: 9, height: 9)
                    Text(speech.isListening ? "শুনছি…" : "READY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.top, 18)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.fromNokshi { bubble(message.text, isNokshi: true); Spacer(minLength: 35) }
                                else { Spacer(minLength: 35); bubble(message.text, isNokshi: false) }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if let error = speech.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.orange).padding(.horizontal)
                }

                HStack(spacing: 10) {
                    Button {
                        speech.toggleListening { recognized in
                            input = recognized
                        }
                    } label: {
                        Image(systemName: speech.isListening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 48, height: 48)
                            .background(neon, in: Circle())
                    }
                    .accessibilityLabel("ভয়েস ইনপুট")

                    TextField("নকশীকে কিছু বলো…", text: $input, axis: .vertical)
                        .lineLimit(1...4)
                        .padding(12)
                        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(neon.opacity(0.35), lineWidth: 1))

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44)
                            .background(neon, in: Circle())
                    }
                    .accessibilityLabel("পাঠাও")
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .onAppear { speech.requestPermissions() }
    }

    @ViewBuilder
    private func bubble(_ text: String, isNokshi: Bool) -> some View {
        Text(text)
            .padding(13)
            .foregroundStyle(.white)
            .background(
                isNokshi ? Color(red: 0.16, green: 0.10, blue: 0.31) : Color(red: 0.06, green: 0.28, blue: 0.34),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(neon.opacity(isNokshi ? 0.25 : 0.55), lineWidth: 1))
    }

    private func sendMessage() {
        let command = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        messages.append(ChatMessage(text: command, fromNokshi: false))
        input = ""

        let reply = handleLocalCommand(command)
        messages.append(ChatMessage(text: reply.text, fromNokshi: true))
        speech.speak(reply.text)

        if let url = reply.url {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func handleLocalCommand(_ command: String) -> (text: String, url: URL?) {
        let c = command.lowercased()

        if c.contains("youtube") || c.contains("ইউটিউব") {
            return ("আচ্ছা বেবি 💜 YouTube খুলতে চেষ্টা করছি।", URL(string: "youtube://") ?? URL(string: "https://www.youtube.com"))
        }
        if c.contains("facebook") || c.contains("ফেসবুক") {
            return ("ঠিক আছে বেবি, Facebook খুলতে চেষ্টা করছি।", URL(string: "fb://") ?? URL(string: "https://www.facebook.com"))
        }
        if c.contains("telegram") || c.contains("টেলিগ্রাম") {
            return ("আচ্ছা বেবি, Telegram খুলতে চেষ্টা করছি।", URL(string: "tg://") ?? URL(string: "https://t.me"))
        }
        if c.contains("ঘুম") || c.contains("sleep") {
            return ("বেবি, রাত হলে একটু বিশ্রাম নিও—তোমার ঘুমও জরুরি। 🌙", nil)
        }
        if c.contains("গান") || c.contains("song") || c.contains("music") {
            return ("আমি এখন ডেমো মোডে আছি। YouTube খুলে গান খুঁজতে পারি, কিন্তু স্বয়ংক্রিয়ভাবে নির্দিষ্ট গান চালানো সবসময় সম্ভব নয়।", URL(string: "https://www.youtube.com"))
        }
        return ("হেই বেবি 💜 আমি এখন প্রাথমিক ডেমো মোডে আছি। এই সংস্করণে পূর্ণ AI যুক্ত নেই; পরে অনুমোদিত AI মডেল যোগ করতে হবে।", nil)
    }
}

final class SpeechManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isListening = false
    @Published var errorMessage: String?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "bn-BD"))
        ?? SFSpeechRecognizer(locale: Locale(identifier: "bn-IN"))
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var onResult: ((String) -> Void)?

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    self.errorMessage = "ভয়েস ব্যবহারের জন্য Speech Recognition অনুমতি দিন।"
                }
            }
        }
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted { self.errorMessage = "ভয়েস ব্যবহারের জন্য Microphone অনুমতি দিন।" }
            }
        }
    }

    func toggleListening(onResult: @escaping (String) -> Void) {
        if isListening {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            request?.endAudio()
            isListening = false
            return
        }
        self.onResult = onResult
        startListening()
    }

    private func startListening() {
        guard let recognizer, recognizer.isAvailable else {
            errorMessage = "এই মুহূর্তে বাংলা speech recognition উপলভ্য নয়।"
            return
        }
        task?.cancel()
        task = nil

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "মাইক্রোফোন চালু করা যায়নি: \(error.localizedDescription)"
            return
        }

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request else { return }
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            errorMessage = nil
        } catch {
            errorMessage = "শোনা শুরু করা যায়নি: \(error.localizedDescription)"
            return
        }

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                let text = result.bestTranscription.formattedString
                DispatchQueue.main.async { self.onResult?(text) }
                if result.isFinal {
                    DispatchQueue.main.async {
                        self.audioEngine.stop()
                        self.audioEngine.inputNode.removeTap(onBus: 0)
                        self.isListening = false
                    }
                }
            }
            if let error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isListening = false
                }
            }
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "bn-BD")
            ?? AVSpeechSynthesisVoice(language: "bn-IN")
        utterance.rate = 0.48
        synthesizer.speak(utterance)
    }
}
