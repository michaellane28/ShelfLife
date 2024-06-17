//
//  ContentView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/12/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // Access the managed object context from the environment
    @Environment(\.managedObjectContext) var viewContext
    
    // Fetch request for PantryItems, sorted by no specific criteria
    @FetchRequest(
        entity: PantryItem.entity(),
        sortDescriptors: []
    ) var pantryItems: FetchedResults<PantryItem>
    
    // Fetch request for FridgeItems, sorted by no specific criteria
    @FetchRequest(
        entity: FridgeItem.entity(),
        sortDescriptors: []
    ) var fridgeItems: FetchedResults<FridgeItem>
    
    // State variable to control the presentation of the Add New Item view
    @State private var showAddNewItemView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Set the background color
                Color(red: 89/255, green: 117/255, blue: 70/255)
                    .edgesIgnoringSafeArea(.all)
                
                // Display the home screen design image
                Image("HomeScreenDesign")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .padding(.bottom, 400)
                    .padding(.top, -194)
                    .zIndex(1)
                
                // Add a rounded rectangle background starting 1/4 down the screen
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(.white)
                    .padding(.top, 150)
                    .edgesIgnoringSafeArea(.bottom)
                
                VStack {
                    // Header for pantry section with navigation to PantryView
                    HStack {
                        Text("What's in your pantry?")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        NavigationLink(destination: PantryView().navigationBarBackButtonHidden(true)) {
                            HStack {
                                Text("View All")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .padding(.trailing, 80)
                    }
                    .padding(.top, 170)
                    
                    // Display message if pantry is empty, otherwise show items
                    if pantryItems.isEmpty {
                        Text("Your pantry is empty")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Horizontal scroll view displaying up to 6 pantry items
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(pantryItems.prefix(6), id: \.self) { item in
                                    VStack(alignment: .leading) {
                                        // Display item category image, name, expiration date, and status
                                        Image(getImageName(for: item.category ?? ""))
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                        Text(item.name ?? "")
                                            .font(.headline)
                                        
                                        HStack {
                                            Text(item.expirationDate ?? Date(), style: .date)
                                                .font(.subheadline)
                                            
                                            // Show expiration status icons
                                            if isExpiringSoon(item.expirationDate ?? Date()) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.yellow)
                                            } else if isExpired(item.expirationDate ?? Date()) {
                                                Image(systemName: "x.circle.fill")
                                                    .foregroundColor(.red)
                                            }
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
                    
                    // Header for fridge section with navigation to FridgeView
                    HStack {
                        Text("What's in your fridge?")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        NavigationLink(destination: FridgeView().navigationBarBackButtonHidden(true)) {
                            HStack {
                                Text("View All")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .padding(.trailing, 80)
                    }
                    .padding(.top, 20)
                    
                    // Display message if fridge is empty, otherwise show items
                    if fridgeItems.isEmpty {
                        Text("Your fridge is empty")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Horizontal scroll view displaying up to 6 fridge items
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(fridgeItems.prefix(6), id: \.self) { item in
                                    VStack(alignment: .leading) {
                                        // Display item category image, name, expiration date, and status
                                        Image(getImageName(for: item.category ?? ""))
                                            .resizable()
                                            .frame(width: 80, height: 80)
                                        Text(item.name ?? "")
                                            .font(.headline)
                                        
                                        HStack {
                                            Text(item.expirationDate ?? Date(), style: .date)
                                                .font(.subheadline)
                                            
                                            // Show expiration status icons
                                            if isExpiringSoon(item.expirationDate ?? Date()) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.yellow)
                                            } else if isExpired(item.expirationDate ?? Date()) {
                                                Image(systemName: "x.circle.fill")
                                                    .foregroundColor(.red)
                                            }
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
                    
                    Spacer()
                }
                
                // Button to show the Add New Item view
                Button {
                    showAddNewItemView = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 250, height: 80)
                            .shadow(radius: 4, x: 0, y: 4)
                            .foregroundColor(Color(red: 89/255, green: 117/255, blue: 70/255))
                        
                        Image("HomeAddButton")
                            .frame(width: 63, height: 20)
                            .padding(.top, 10)
                    }
                }
                .padding(.top, 400)
                .padding(.bottom, -200)
            }
            .fullScreenCover(isPresented: $showAddNewItemView) {
                BulkAddNewItemsView()
            }
        }
    }
    
    // Function to check if an item is expiring soon (within 3 days)
    func isExpiringSoon(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expirationDay = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: today, to: expirationDay).day ?? 0
        return diff <= 3 && diff > 0
    }
       
    // Function to check if an item is expired
    func isExpired(_ date: Date) -> Bool {
        return date < Date()
    }
    
    // Function to get the image name based on the category of the item
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
        case "Dairy":
            return "Dairy"
        case "Fruits & Vegetables":
            return "FruitsVegetables"
        case "Meats":
            return "Meats"
        case "FridgeCondiments":
            return "FridgeCondiments"
        case "FridgeOther":
            return "FridgeOther"
        default:
            return ""
        }
    }
}

struct RoundedBar: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .foregroundColor(Color(red: 89/255, green: 117/255, blue: 70/255))
            .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
