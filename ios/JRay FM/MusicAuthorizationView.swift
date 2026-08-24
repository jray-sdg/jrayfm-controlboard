//
//  MusicAuthorizarionView.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import MusicKit
import SwiftUI

struct MusicAuthorizationView: View {
    @Bindable var authManager: MusicAuthorizationManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            actionButton
        }
        .padding()
    }
    
    private var title: String {
        switch authManager.status {
        case .notDetermined: "Connect Music Library"
        case .denied: "Access Denied"
        case .restricted: "Access Restricted"
        default: ""
        }
    }
    
    private var message: String {
        switch authManager.status {
        case .notDetermined:
            "This app needs permission to see your music library to build playlists from it."
        case .denied:
            "You've previously denied access. You can change this in Settings."
        case .restricted:
            "Music library access is restricted on this device, possibly by parental controls or a device management policy."
        default:
            ""
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch authManager.status {
        case .notDetermined:
            Button("Continue") {
                Task { await authManager.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
            
        case .denied:
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            
        case .restricted:
            EmptyView()
            
        default:
            EmptyView()
        }
    }
}
