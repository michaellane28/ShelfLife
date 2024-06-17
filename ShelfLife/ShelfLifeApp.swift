//
//  ShelfLifeApp.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//

import SwiftUI

@main
struct YourApp: App {
    @AppStorage(UserDefaultsKeys.hasCompletedInitialSetup) var hasCompletedInitialSetup: Bool = false
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        
        // Checks to see if user has opened the app before
        WindowGroup {
            if hasCompletedInitialSetup {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                WelcomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
