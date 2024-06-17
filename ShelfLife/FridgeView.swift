//
//  FridgeView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//

import SwiftUI
import CoreData

struct FridgeView: View {
    // Core Data context
    @Environment(\.managedObjectContext) var viewContext
    // Presentation mode for dismissing view
    @Environment(\.presentationMode) var presentationMode
    
    // State for showing the add new item view
    @State private var showingAddNewItemView = false
    // Fetching fridge items sorted by creation date
    @FetchRequest(
        entity: FridgeItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FridgeItem.createdAt, ascending: true)]
    ) var fridgeItems: FetchedResults<FridgeItem>
    
    // State for expanded sections in the list
    @State private var expandedSections: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Custom top bar
                RoundedBar()
                    .frame(height: 110)
                    .zIndex(1)
                
                List {
                    // Spacer for top padding
                    Spacer().frame(height: 80)
                        .listRowSeparator(.hidden)
                    
                    // Section for items expiring soon
                    Section(header: Text("Expiring Soon").font(.title2).padding(.horizontal)) {
                        // Display message if no items are expiring soon
                        if fridgeItems.filter { isExpiringSoon($0.expirationDate ?? Date()) }.isEmpty {
                            Text("You do not have any items expiring soon.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            // Scrollable list of items expiring soon
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(fridgeItems.filter { isExpiringSoon($0.expirationDate ?? Date())}, id: \.self) { item in
                                        // Individual item view
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
                        // For each category, show a disclosure group
                        ForEach(["Dairy", "Condiments", "Fruits & Vegetables", "Meats", "Other"], id: \.self) { category in
                            // Disclosure group for each category
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
                                    // List of items in the category
                                    ForEach(fridgeItems.filter { $0.category == category }) { item in
                                        HStack {
                                            Text(item.name ?? "")
                                            Spacer()
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
                                    // Delete items in category
                                    .onDelete { indexSet in
                                        deleteItems(at: indexSet, in: category)
                                    }
                                },
                                label: {
                                    // Category label
                                    HStack {
                                        Image(getImageName(for: category))
                                            .resizable()
                                            .frame(width: 48, height: 48)
                                        Text(category)
                                    }
                                    .padding(.horizontal)
                                }
                            )
                        }
                    }.listRowSeparator(.hidden)
                    
                    // Section for expired items
                    Section(header: Text("Expired").font(.title2).padding(.horizontal)) {
                        // Display message if no items are expired
                        if fridgeItems.filter { isExpired($0.expirationDate ?? Date()) }.isEmpty {
                            Text("You do not have any expired items.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        } else {
                            // Scrollable list of expired items
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(fridgeItems.filter { isExpired($0.expirationDate ?? Date())}, id: \.self) { item in
                                        // Individual expired item view
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
                .toolbar {
                    // Toolbar items
                    ToolbarItem(placement: .navigationBarLeading) {
                        backButton
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addButton
                    }
                    ToolbarItem(placement: .principal) {
                        Image("FridgeDoor")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                    }
                }
                .toolbarBackground(.hidden)
            }
            .edgesIgnoringSafeArea(.top)
            .fullScreenCover(isPresented: $showingAddNewItemView) {
                // Full screen add new item view
                AddNewFridgeItemView()
                    .ignoresSafeArea(.keyboard)
                    .presentationDetents([
                        .custom(CustomDetent.self)
                    ])
            }
        }
    }
    
    // Delete items from category
    func deleteItems(at offsets: IndexSet, in category: String) {
        for offset in offsets {
            let items = fridgeItems.filter { $0.category == category }
            let item = items[offset]
            viewContext.delete(item)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    // Back button
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 60, height: 40)
                .foregroundColor(.clear)
                .overlay(
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                )
        }
    }
    
    // Add button
    var addButton: some View {
        Button(action: {
            self.showingAddNewItemView = true
        }) {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 60, height: 40)
                .foregroundColor(.clear)
                .overlay(
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                )
        }
    }
    
    // Check if item is expiring soon
    func isExpiringSoon(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expirationDay = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: today, to: expirationDay).day ?? 0
        return diff <= 3 && diff > 0
    }
    
    // Check if item is expired
    func isExpired(_ date: Date) -> Bool {
        return date < Date()
    }
    
    // Get image name for category
    func getImageName(for category: String) -> String {
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

// Custom presentation detent
struct CustomDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        return context.maxDetentValue - 1
    }
}

struct FridgeView_Previews: PreviewProvider {
    static var previews: some View {
        FridgeView()
    }
}
