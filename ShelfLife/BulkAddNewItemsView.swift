//
//  BulkAddNewItemsView.swift
//  ShelfLife
//
//  Created by Michael Lane on 6/16/24.
//

import SwiftUI
import CoreData

struct BulkAddNewItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Fetch request variables for tracking the PantryItems and FridgeItems
    @FetchRequest(
        entity: PantryItem.entity(),
        sortDescriptors: []
    ) var pantryItems: FetchedResults<PantryItem>
    
    @FetchRequest(
        entity: FridgeItem.entity(),
        sortDescriptors: []
    ) var fridgeItems: FetchedResults<FridgeItem>
    
    
    @State private var isPresentingAddNewItem = false
    @AppStorage(UserDefaultsKeys.hasCompletedInitialSetup) private var hasCompletedInitialSetup: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                
                // Opens InitialAddNewItemView
                Button(action: {
                    isPresentingAddNewItem.toggle()
                }) {
                    Text("+Add New Item")
                }
                
                // Displays added PantryItems
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
                
                // Displays added FridgeItems
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
            .navigationTitle("Bulk Add Items")
            .navigationBarItems(trailing:
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $isPresentingAddNewItem) {
                InitialAddNewItemView()
            }
        }
    }
    
    // Delete the selected PantryItem
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
    
    // Delete the selected FridgeItem
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
    
    // Get the image name for a given category
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

struct BulkAddNewItemsView_Previews: PreviewProvider {
    static var previews: some View {
        InitialSetupView()
    }
}
