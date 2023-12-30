//
//  ShoePickerView.swift
//  myles
//
//  Created by Max Rogers on 12/30/23.
//

import SwiftUI

struct ShoePickerView: View {
    
    @EnvironmentObject var shoes: ShoeManager
    
    @State var newShoe: String = ""
    
    var body: some View {
        // TODO List with shoes + single selection binding / style + add shoe button / text input
        // Shoe Name + footnote with current miles
        
        NavigationStack {
            List {
                Section {
                    ForEach(shoes.shoes) { shoe in
                        VStack(alignment: .leading) {
                            Text(shoe.name)
                                .font(.largeTitle)
                            Text("\(shoe.miles)")
                                .font(.footnote)
                        }
                    }
                }
                Section {
                    TextField("New Shoe", text: $newShoe)
                        .textInputAutocapitalization(.never)
                }
            }
        }
        .navigationTitle("Shoes")
        .onSubmit(addNewShoe)
        .presentationDetents([.medium])
    }
    
    private func addNewShoe() {
        withAnimation {
            // TODO add shoe
            newShoe = ""
        }
    }
}

#Preview {
    ShoePickerView()
}
