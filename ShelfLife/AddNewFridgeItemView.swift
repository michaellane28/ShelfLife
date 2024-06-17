//
//  AddNewFridgeItemView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/14/24.
//

import SwiftUI

struct AddNewFridgeItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var itemName = ""
    @State private var expirationDate = Date()
    @State private var selectedCategory: String? // Track the selected category
    
    // Add a flag to track if the user intends to save the item
    @State private var saveItem = false
    
    let categories = ["Dairy", "Condiments", "Fruits & Vegetables", "Meats", "Other"]
    
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    
                    Form {
                        // Section for entering the item name
                        Section(header: Text("Item Details")) {
                            TextField("Name", text: $itemName)
                        }
                        
                        // Section for selecting the category
                        Section(header: Text("Category")) {
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 10) {
                                HStack {
                                    // Display category images in a grid
                                    ForEach(categories, id: \.self) { category in
                                        Image(getImageName(for: category))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                // Add a blue border to the selected category
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
                        
                        // Section for selecting the expiration date
                        Section(header: Text("Expiration Date")) {
                            DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Add New Fridge Item")
                    .toolbar {
                        // Add a cancel button to dismiss the view
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }.foregroundColor(.blue)
                        }
                    }
                }
                
                // Save button at the bottom of the screen
                VStack {
                    Spacer()
                    Button {
                        // Validate form before saving
                        if itemName.isEmpty || selectedCategory == nil {
                            showAlert = true
                        } else {
                            saveNewItem()
                            saveItem = true
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 125, height: 60)
                                .shadow(radius: 4, x: 0, y: 4)
                                .foregroundColor(Color(red: 89/255, green: 117/255, blue: 70/255))

                            Text("Save")
                                .foregroundColor(.white)
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        // Show an alert if form is incomplete
                        Alert(title: Text("Incomplete Form"), message: Text("All fields must be completed."), dismissButton: .default(Text("OK")))
                    }
                }
            }
        }
        .onDisappear {
            // Rollback changes if the item was not saved
            if !saveItem {
                viewContext.rollback()
            }
        }
    }
    
    // Function to save a new item to the database
    private func saveNewItem() {
        withAnimation {
            let newItemCreationDate = Date()
            
            let newItem = FridgeItem(context: viewContext)
            newItem.id = UUID()
            newItem.name = itemName
            newItem.expirationDate = expirationDate
            newItem.createdAt = newItemCreationDate
            newItem.category = selectedCategory ?? ""
            
            // Attempt to save the new item
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // Function to get the image name for a given category
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
        default:
            return ""
        }
    }
}

struct AddNewFridgeItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewFridgeItemView()
    }
}
