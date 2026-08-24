//
//  JRay_FMApp.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import AVFoundation
import SwiftUI
import SwiftData

@main
struct JRay_FMApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LibrarySong.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}
