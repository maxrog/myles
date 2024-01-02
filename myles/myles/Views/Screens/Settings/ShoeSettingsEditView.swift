//
//  ShoeSettingsEditView.swift
//  myles
//
//  Created by Max Rogers on 1/2/24.
//

import SwiftUI

/// View to edit a shoe's name
struct ShoeSettingsEditView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var shoes: ShoeManager
    
    @State var editedName = ""
    @State var editing = false
    @FocusState var textFieldFocused: Bool
    
    var index: Int
    var shoe: MylesShoe
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(shoe.name, text: $editedName)
                .lineLimit(1)
                .font(.custom("norwester", size: 22))
                .submitLabel(.done)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(!editing)
                .focused($textFieldFocused)
                .onTapGesture {
                    toggleTextField(enabled: true)
                }
            Text("\(shoe.miles.prettyString) miles")
                .font(.custom("norwester", size: 14))
                .foregroundColor(Color(.systemGray2))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .onSubmit {
            modifyShoeName(shoe, at: index)
        }
        .swipeActions {
            Button() {
                toggleTextField(enabled: true)
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
    
    @MainActor
    func deleteShoe(at index: Int) {
        withAnimation {
            shoes.deleteShoe(at: index)
        }
    }
    
    @MainActor
    func modifyShoeName(_ shoe: MylesShoe, at index: Int) {
        guard !editedName.isEmpty else {
            toggleTextField(enabled: false)
            return
        }
        let updatedShoe = shoe
        updatedShoe.name = editedName
        shoes.modifyShoe(updatedShoe, at: index)
        editedName = ""
        toggleTextField(enabled: false)
    }
    
    @MainActor
    func toggleTextField(enabled: Bool) {
        editing = enabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            self.textFieldFocused = enabled
        }
    }
}

#Preview {
    ShoeSettingsEditView(index: 0, shoe: MylesShoe(name: "Test Shoe"))
}
