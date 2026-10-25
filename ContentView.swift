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
        ChatMessage(text: "হ্যালো! আমি নকশি AI। কীভাবে সাহায্য করতে পারি?", fromNokshi: true)
    ]
    @State private var speaking = false
    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.025, green: 0.035, blue: 0.10),
                         Color(red: 0.08, green: 0.02, blue: 0.16)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("NOKSHI AI")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("YOUR PERSONAL AI ASSISTANT")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(.cyan)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.purple)
                }
                .padding(.top, 12)

                HStack {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("ডেমো মোডে প্রস্তুত")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                    Spacer()
                    Button {
                        speakLastReply()
                    } label: {
                        Label("শুনুন", systemImage: "speaker.wave.2.fill")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(.cyan)
                }

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.fromNokshi { Spacer(minLength: 35) }
                                Text(message.text)
                                    .font(.system(size: 15))
                                    .foregroundStyle(.white)
                                    .padding(13)
                                    .background(
                                        message.fromNokshi
                                        ? Color.purple.opacity(0.32)
                                        : Color.cyan.opacity(0.18)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(message.fromNokshi ? Color.purple.opacity(0.7) : Color.cyan.opacity(0.55), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                if !message.fromNokshi { Spacer(minLength: 35) }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                HStack(spacing: 10) {
                    TextField("এখানে লিখুন…", text: $input, axis: .vertical)
                        .lineLimit(1...4)
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.18)))

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 46, height: 46)
                            .background(Color.cyan)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Text("এটি একটি প্রাথমিক ডেমো; অনলাইন AI সংযোগ এখনো যোগ করা হয়নি।")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
        }
    }

    private func sendMessage() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, fromNokshi: false))
        input = ""
        messages.append(ChatMessage(
            text: "তোমার বার্তাটি পেয়েছি। আমি এখন ডেমো মোডে আছি—বাস্তব AI উত্তর পেতে একটি AI API/backend সংযোগ করতে হবে।",
            fromNokshi: true
        ))
    }

    private func speakLastReply() {
        guard let last = messages.last(where: { $0.fromNokshi }) else { return }
        let utterance = AVSpeechUtterance(string: last.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "bn-BD") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.48
        synthesizer.speak(utterance)
    }
}
