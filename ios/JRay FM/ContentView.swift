//
//  ContentView.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import MusicKit
import SwiftUI

struct ContentView: View {
    @State private var authManager = MusicAuthorizationManager()

    var body: some View {
        Group {
            if authManager.isAuthorized {
                NowPlayingView()
            } else {
                MusicAuthorizationView(authManager: authManager)
            }
        }
        .task {
            if authManager.status == .notDetermined {
                await authManager.requestAuthorization()
            }
        }
    }
}

#Preview {
    ContentView()
}
