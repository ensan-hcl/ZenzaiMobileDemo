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
    var body: some View {
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
    }

    private var options: ConvertRequestOptions {
        .withDefaultDictionary(
            requireJapanesePrediction: false,
            requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP,
            learningType: .nothing,
            memoryDirectoryURL: .applicationDirectory,
            sharedContainerURL: .applicationDirectory,
            zenzaiMode: .on(weight: Bundle.main.bundleURL.appending(path: "ggml-model-Q8_0.gguf"), inferenceLimit: 1),
            metadata: nil
        )
    }
}

#Preview {
    ContentView()
}
