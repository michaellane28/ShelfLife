//
//  InitialAddNewItemView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//
// View for allowing users to add their initial items when they first open the application

import SwiftUI
import CoreData

struct InitialAddNewItemView: View {
    // Environment variables for CoreData context and presentation mode
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for form fields and alert
    @State private var itemName = ""
    @State private var selectedStorageType = "Pantry"
    @State private var expirationDate = Date()
    @State private var selectedCategory: String? = nil
    @State private var showAlert = false
    
    // Categories for pantry and fridge items
    let pantryCategories = ["Grains & Pastas", "Snacks", "Canned Goods", "Condiments", "Other"]
    let fridgeCategories = ["Dairy", "Condiments", "Fruits & Vegetables", "Meats", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Section for item details
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $itemName)
                    Picker("Storage Type", selection: $selectedStorageType) {
                        Text("Pantry").tag("Pantry")
                        Text("Fridge").tag("Fridge")
                    }
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                }
                
                // Section for selecting category
                Section(header: Text("Category")) {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                        HStack {
                            ForEach(selectedStorageType == "Pantry" ? pantryCategories : fridgeCategories, id: \.self) { category in
                                Image(getImageName(for: category))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(Color.blue, lineWidth: selectedCategory == category ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                            }
                        }
                    }
                }
                
                // Section for save button
                Section {
                    HStack {
                        Spacer()
                        Button(action: {
                            if itemName.isEmpty || selectedCategory == nil {
                                showAlert = true
                            } else {
                                saveNewItem()
                            }
                        }) {
                            Text("Save")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Incomplete Form"), message: Text("All fields must be completed."), dismissButton: .default(Text("OK")))
            }
        }
        .onDisappear {
            viewContext.rollback() // Rollback changes if the view disappears without saving
        }
    }
    
    // Function to save the new item
    private func saveNewItem() {
        withAnimation {
            let newItemID = UUID()
            let newItemCreationDate = Date()
            
            // Create new item based on selected storage type
            if selectedStorageType == "Pantry" {
                let newItem = PantryItem(context: viewContext)
                newItem.id = newItemID
                newItem.name = itemName
                newItem.expirationDate = expirationDate
                newItem.createdAt = newItemCreationDate
                newItem.category = selectedCategory ?? ""
            } else {
                let newItem = FridgeItem(context: viewContext)
                newItem.id = newItemID
                newItem.name = itemName
                newItem.expirationDate = expirationDate
                newItem.createdAt = newItemCreationDate
                newItem.category = selectedCategory ?? ""
            }
            
            // Save the context
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Function to get the image name based on category
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

// Preview for InitialAddNewItemView
struct InitialAddNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        InitialAddNewItemView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
