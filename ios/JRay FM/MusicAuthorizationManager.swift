//
//  MusicAuthorizationManager.swift
//  JRay FM
//
//  Created by Jonathan Ray on 6/27/26.
//

import MusicKit
import Observation

@Observable
final class MusicAuthorizationManager {
    private(set) var status: MusicAuthorization.Status
    
    init () {
        self.status = MusicAuthorization.currentStatus
    }
    
    var isAuthorized: Bool {
        status == .authorized
    }
    
    @MainActor
    func requestAuthorization() async {
        guard status != .authorized else { return }
        let newStatus = await MusicAuthorization.request()
        status = newStatus
    }
}
