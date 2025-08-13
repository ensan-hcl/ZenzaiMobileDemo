//
//  ContentView.swift
//  ZenzaiMobile
//
//  Created by miwa on 2024/05/15.
//

import KanaKanjiConverterModuleWithDefaultDictionary
import SwiftUI

@MainActor
struct ContentView: View {
    @State private var input = ""
    @State private var output = ""
    @State private var exectime = ""
    @State private var converter = KanaKanjiConverter()
    @State private var zenzaiEnabled = true
    @State private var zenzaiInferenceLimit = 1
    @State private var presentInspector = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Zenzai Japanese Input")
                    .font(.title)
                if !output.isEmpty {
                    Text(verbatim: "\(output) (\(exectime) ms)")
                }
                TextField("type kana here", text: $input)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .onChange(of: input, initial: false) {
                var c = ComposingText()
                c.insertAtCursorPosition(input, inputStyle: .direct)
                let s = Date()
                let res = converter.requestCandidates(c, options: options)
                self.output = res.mainResults.first?.text ?? "Error"
                self.exectime = String(-s.timeIntervalSinceNow * 1000)
            }
            .sheet(isPresented: $presentInspector) {
                Form {
                    Section {
                        Toggle("Enable Zenzai", isOn: $zenzaiEnabled)
                        Stepper("Inference Limit \(zenzaiInferenceLimit)", value: $zenzaiInferenceLimit, in: 1...10)
                            .disabled(!self.zenzaiEnabled)
                    }
                }
                .presentationDetents([.medium])
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Preferences", systemImage: "gearshape") {
                        presentInspector.toggle()
                    }
                }
            }
        }
    }

    private var options: ConvertRequestOptions {
        let zenzaiMode: ConvertRequestOptions.ZenzaiMode = self.zenzaiEnabled ? .on(
            weight: Bundle.main.bundleURL.appending(
                path: "ggml-model-Q5_K_M.gguf"
            ),
            inferenceLimit: self.zenzaiInferenceLimit,
            personalizationMode: nil
        ) : .off
        return .withDefaultDictionary(
            requireJapanesePrediction: false,
            requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP,
            learningType: .nothing,
            memoryDirectoryURL: .applicationDirectory,
            sharedContainerURL: .applicationDirectory,
            zenzaiMode: zenzaiMode,
            metadata: nil
        )
    }
}

#Preview {
    ContentView()
}
