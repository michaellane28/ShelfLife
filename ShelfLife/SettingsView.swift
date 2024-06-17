//
//  SettingsView.swift
//  ShelfLife
//
//  Created by Michael Lane on 5/16/24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .top){
                RoundedBar()
                    .frame(height: 110)// Place the RoundedBar at the top
                
                Text("Settings")
                    .padding(.top, 65)
                    .foregroundColor(.white)
                
                VStack {
                    Spacer()
                    Text("Settings Content")
                        .navigationBarTitle("")
                    Spacer()
                }
                .navigationBarItems(leading: backButton)
                .padding(.top, 50)
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
    
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
