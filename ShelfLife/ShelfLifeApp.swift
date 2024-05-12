//
//  ShelfLifeApp.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//

import SwiftUI

@main
struct ShelfLifeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
