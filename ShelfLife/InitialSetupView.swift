//
//  InitialSetupView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//
//

import SwiftUI
import CoreData

struct InitialSetupView: View {
    // Environment and FetchRequest variables
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: PantryItem.entity(),
        sortDescriptors: []
    ) var pantryItems: FetchedResults<PantryItem>
    
    @FetchRequest(
        entity: FridgeItem.entity(),
        sortDescriptors: []
    ) var fridgeItems: FetchedResults<FridgeItem>
    
    // State variables
    @State private var isPresentingAddNewItem = false
    @AppStorage(UserDefaultsKeys.hasCompletedInitialSetup) private var hasCompletedInitialSetup: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                // Button to present the Add New Item view
                Button(action: {
                    isPresentingAddNewItem.toggle()
                }) {
                    Text("Add New Item")
                }
                
                // Section displaying pantry items
                Section(header: Text("Pantry Items")) {
                    ForEach(pantryItems, id: \.self) { item in
                        if let name = item.name, let expirationDate = item.expirationDate, let category = item.category {
                            HStack {
                                Image(getImageName(for: category))
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text(name)
                                Spacer()
                                Text(DateFormatter.shortDate.string(from: expirationDate))
                            }
                        } else {
                            Text("Unknown Item")
                        }
                    }
                    .onDelete(perform: deletePantryItem)
                }
                
                // Section displaying fridge items
                Section(header: Text("Fridge Items")) {
                    ForEach(fridgeItems, id: \.self) { item in
                        if let name = item.name, let expirationDate = item.expirationDate, let category = item.category {
                            HStack {
                                Image(getImageName(for: category))
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text(name)
                                Spacer()
                                Text(DateFormatter.shortDate.string(from: expirationDate))
                            }
                        } else {
                            Text("Unknown Item")
                        }
                    }
                    .onDelete(perform: deleteFridgeItem)
                }
            }
            .navigationTitle("Initial Setup")
            .navigationBarItems(trailing:
                // Button to mark initial setup as complete
                Button("Done") {
                    hasCompletedInitialSetup = true
                    presentationMode.wrappedValue.dismiss()
                }
            )
            // Sheet for adding a new item
            .sheet(isPresented: $isPresentingAddNewItem) {
                InitialAddNewItemView()
            }
        }
    }
    
    // Function to delete pantry items
    private func deletePantryItem(at offsets: IndexSet) {
        for index in offsets {
            let item = pantryItems[index]
            viewContext.delete(item)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // Function to delete fridge items
    private func deleteFridgeItem(at offsets: IndexSet) {
        for index in offsets {
            let item = fridgeItems[index]
            viewContext.delete(item)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // Function to get image name based on category
    private func getImageName(for category: String) -> String {
        switch category {
        case "Dairy":
            return "Dairy"
        case "Condiments":
            return "FridgeCondiments"
        case "Fruits & Vegetables":
            return "FruitsVegetables"
        case "Meats":
            return "Meats"
        case "Other":
            return "FridgeOther"
        case "Grains & Pastas":
            return "Grains & Pastas"
        case "Snacks":
            return "Snacks"
        case "Canned Goods":
            return "Canned Goods"
        default:
            return ""
        }
    }
}

// Preview for InitialSetupView
struct InitialSetupView_Previews: PreviewProvider {
    static var previews: some View {
        InitialSetupView()
    }
}

// Extension to format dates
extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter
    }()
}
