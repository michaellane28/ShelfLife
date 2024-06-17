//
//  PantryView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//

import SwiftUI
import CoreData

struct PantryView: View {
    // Core Data managed object context for data operations
    @Environment(\.managedObjectContext) var viewContext
    // Presentation mode for dismissing the view
    @Environment(\.presentationMode) var presentationMode
    
    // State variable to control the presentation of the AddNewPantryItemView
    @State private var showingAddNewItemView = false
    // Fetch request to retrieve pantry items sorted by creation date
    @FetchRequest(
        entity: PantryItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PantryItem.createdAt, ascending: true)]
    ) var pantryItems: FetchedResults<PantryItem>
    
    // Set to keep track of expanded sections in the list
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        // Navigation stack for the view
        NavigationStack {
            // ZStack to layer views
            ZStack(alignment: .top) {
                // Custom rounded bar at the top of the screen
                RoundedBar()
                    .frame(height: 110)
                    .zIndex(1)
                
                // List to display pantry items
                List {
                    // Spacer to create space between the top and the list
                    Spacer().frame(height: 80)
                        .listRowSeparator(.hidden)
                    
                    // Section for items expiring soon
                    Section(header: Text("Expiring Soon").font(.title2).padding(.horizontal)) {
                        // Check if there are no items expiring soon
                        if pantryItems.filter { isExpiringSoon($0.expirationDate ?? Date()) }.isEmpty {
                            // Display message if no items are expiring soon
                            Text("You do not have any items expiring soon.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        else {
                            // Display items expiring soon in a horizontal scroll view
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    // Iterate over expiring items and display them
                                    ForEach(pantryItems.filter { isExpiringSoon($0.expirationDate ?? Date())}, id: \.self) { item in
                                        // Display item information in a card-like format
                                        VStack(alignment: .leading) {
                                            Image(getImageName(for: item.category ?? ""))
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                            Text(item.name ?? "")
                                                .font(.headline)
                                            
                                            HStack {
                                                Text(item.expirationDate ?? Date(), style: .date)
                                                    .font(.subheadline)
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.yellow)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                            }
                        }
                    }.listRowSeparator(.hidden)
                    
                    // Section for categories
                    Section(header: Text("Categories").font(.title2).padding(.horizontal)) {
                        // Iterate over categories to display items grouped by category
                        ForEach(["Grains & Pastas", "Snacks", "Canned Goods", "Condiments", "Other"], id: \.self) { category in
                            // Disclosure group for each category to expand and collapse items
                            DisclosureGroup(
                                isExpanded: Binding(
                                    get: { expandedSections.contains(category) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedSections.insert(category)
                                        } else {
                                            expandedSections.remove(category)
                                        }
                                    }
                                ),
                                content: {
                                    // Display items in the category
                                    ForEach(pantryItems.filter { $0.category == category }) { item in
                                        HStack {
                                            Text(item.name ?? "")
                                            Spacer()
                                            // Display icon based on item expiration status
                                            if isExpiringSoon(item.expirationDate ?? Date()) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.yellow)
                                                
                                            } else if isExpired(item.expirationDate ?? Date()) {
                                                Image(systemName: "x.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                            Text(item.expirationDate ?? Date(), style: .date)
                                        }
                                        .padding(.horizontal)
                                    }
                                    // Allow deleting items from the category
                                    .onDelete { indexSet in
                                        deleteItems(at: indexSet, in: category)
                                    }
                                },
                                label: {
                                    // Display category name and icon
                                    HStack {
                                        Image(getImageName(for: category))
                                            .resizable()
                                            .frame(width: 48, height: 48) // Adjust the size as needed
                                        Text(category)
                                    }
                                    .padding(.horizontal)
                                }
                            )
                        }
                    }.listRowSeparator(.hidden)
                    
                    // Section for expired items
                    Section(header: Text("Expired").font(.title2).padding(.horizontal)) {
                        // Check if there are no expired items
                        if pantryItems.filter { isExpired($0.expirationDate ?? Date()) }.isEmpty {
                            // Display message if no items are expired
                            Text("You do not have any expired items.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            // Display expired items in a horizontal scroll view
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    // Iterate over expired items and display them
                                    ForEach(pantryItems.filter { isExpired($0.expirationDate ?? Date())}, id: \.self) { item in
                                        // Display item information in a card-like format
                                        VStack(alignment: .leading) {
                                            Image(getImageName(for: item.category ?? ""))
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                            Text(item.name ?? "")
                                                .font(.headline)
                                            
                                            HStack {
                                                Text(item.expirationDate ?? Date(), style: .date)
                                                    .font(.subheadline)
                                                Image(systemName: "x.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(radius: 4)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 5)
                            }
                        }
                    }.listRowSeparator(.hidden)
                    
                }
                .listStyle(PlainListStyle())
                // Toolbar items for navigation bar
                .toolbar {
                    // Back button
                    ToolbarItem(placement: .navigationBarLeading) {
                        backButton
                    }
                    // Add button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
                    }
                    // Image logo in the center
                    ToolbarItem(placement: .principal) {
                        Image("PantryDoor")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35) // Adjust the size as needed
                    }
                }
                .toolbarBackground(.hidden)
            }
            .edgesIgnoringSafeArea(.top)
            // Full screen cover for AddNewPantryItemView
            .fullScreenCover(isPresented: $showingAddNewItemView) {
                AddNewPantryItemView()
                    .ignoresSafeArea(.keyboard)
                    .presentationDetents([
                        .custom(CustomDetent.self)
                    ])
            }
        }
    }
    
    // Function to delete items at specified offsets in a category
    func deleteItems(at offsets: IndexSet, in category: String) {
        for offset in offsets {
            let items = pantryItems.filter { $0.category == category }
            let item = items[offset]
            viewContext.delete(item)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    // Back button for the navigation bar
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            RoundedRectangle(cornerRadius: 30) // Rounded Rectangle as button background
                .frame(width: 60, height: 40)
                .foregroundColor(.clear)
                .overlay(
                    HStack {
                        Image(systemName: "arrow.left") // Back arrow icon
                            .foregroundColor(.white) // Icon color
                    }
                )
        }
    }
    
    // Add button for the navigation bar
    var addButton: some View {
        Button(action: {
            self.showingAddNewItemView = true
        }) {
            RoundedRectangle(cornerRadius: 30) // Rounded Rectangle as button background
                .frame(width: 60, height: 40)
                .foregroundColor(.clear)
                .overlay(
                    HStack {
                        Image(systemName: "plus") // Plus icon
                            .foregroundColor(.white) // Icon color
                    }
                )
        }
    }
    
    // Function to check if a date is expiring soon (within 3 days)
    func isExpiringSoon(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expirationDay = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: today, to: expirationDay).day ?? 0
        return diff <= 3 && diff > 0
    }
    
    // Function to check if a date is expired
    func isExpired(_ date: Date) -> Bool {
        return date < Date()
    }
    
    // Function to get the image name based on the category
    func getImageName(for category: String) -> String {
        switch category {
        case "Grains & Pastas":
            return "Grains & Pastas"
        case "Snacks":
            return "Snacks"
        case "Canned Goods":
            return "Canned Goods"
        case "Condiments":
            return "Condiments"
        case "Other":
            return "Other"
        default:
            return ""
        }
    }
}

struct PantryView_Previews: PreviewProvider {
    static var previews: some View {
        PantryView()
    }
}
 
