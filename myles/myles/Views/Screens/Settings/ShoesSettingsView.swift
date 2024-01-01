//
//  ShoesSettingsView.swift
//  myles
//
//  Created by Max Rogers on 1/1/24.
//

import SwiftUI

/*
 TODO selection of shoe should show a list of all runs
 TODO editing name flow is a little choppy + design / UX could be improved
 */

/// Settings view for modifying user's tracked shoes
struct ShoesSettingsView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var shoes: ShoeManager
        
    @State var editingIndex: Int?
    @State var editedName = ""
    @State var newShoe: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(shoes.shoes.enumerated()), id: \.element) { index, shoe in
                        VStack(alignment: .leading) {
                            if editingIndex == index {
                                HStack {
                                    TextField(shoe.name, text: $editedName)
                                        .font(.custom("norwester", size: 16))
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                    Button {
                                        modifyShoeName(shoe, at: index)
                                    } label: {
                                        Text("Save")
                                            .font(.custom("norwester", size: 22))
                                    }
                                    .buttonStyle(MylesButtonStyle())
                                }
                            } else {
                                Text(shoe.name)
                                    .font(.custom("norwester", size: 22))
                                Text("\(shoe.miles.prettyString) miles")
                                    .font(.custom("norwester", size: 14))
                                    .foregroundColor(Color(.systemGray2))
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .swipeActions {
                            Button() {
                                withAnimation {
                                    editingIndex = index
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }
                            Button(role: .destructive) {
                                // TODO confirmation alert to delete
                                deleteShoe(at: index)
                            } label: {
                                Image(systemName: "delete.backward.fill")
                            }
                        }
                    }
                }
                Section {
                    TextField("Add Shoe", text: $newShoe)
                        .font(.custom("norwester", size: 16))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle("Shoes")
        }
        .onSubmit(addNewShoe)
    }
    
    private func addNewShoe() {
        withAnimation {
            shoes.addShoe(MylesShoe(name: newShoe))
            newShoe = ""
        }
    }
    
    private func deleteShoe(at index: Int) {
        withAnimation {
            shoes.deleteShoe(at: index)
        }
    }
    
    private func modifyShoeName(_ shoe: MylesShoe, at index: Int) {
        let updatedShoe = shoe
        updatedShoe.name = editedName
        withAnimation {
            shoes.modifyShoe(updatedShoe, at: index)
            editedName = ""
            editingIndex = nil
        }
    }
}

#Preview {
    ShoesSettingsView()
}
