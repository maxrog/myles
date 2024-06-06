//
//  ShoeSettingsEditView.swift
//  myles
//
//  Created by Max Rogers on 1/2/24.
//

import SwiftUI

// TODO add TipKit for swipe action

/// View to edit a shoe's name
struct ShoeSettingsEditView: View {

    enum FocusedField {
        case name, miles
    }

    @EnvironmentObject var theme: ThemeManager
    @Environment(ShoeManager.self) var shoes

    @FocusState private var focusedField: FocusedField?
    @State var editing = false

    @State var editedName = ""
    @State var editedMiles = ""

    var index: Int
    var shoe: MylesShoe

    var body: some View {
        VStack(alignment: .leading) {
            TextField(shoe.name, text: $editedName)
                .lineLimit(1)
                .font(.custom("norwester", size: 22))
                .submitLabel(.next)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(!editing)
                .onTapGesture {
                    focusedField = .name
                }
                .onSubmit {
                    if !editedName.isEmpty {
                        shoe.name = editedName
                    }
                    focusedField = .miles
                }
                .focused($focusedField, equals: .name)

            TextField(shoe.miles.prettyString, text: $editedMiles)
                .lineLimit(1)
                .font(.custom("norwester", size: 14))
                .keyboardType(.decimalPad)
                .submitLabel(.done)
                .disabled(!editing)
                .onTapGesture {
                    focusedField = .miles
                }
                .focused($focusedField, equals: .miles)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Save") {
                    if !editedName.isEmpty {
                        shoe.name = editedName
                    }
                    if !editedMiles.isEmpty, let newMiles = Double(editedMiles) {
                        shoe.miles = newMiles
                    }
                    modifyShoe()
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .swipeActions {
            Button {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    editing = true
                    focusedField = .name
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

    @MainActor
    func deleteShoe(at index: Int) {
        withAnimation {
            shoes.deleteShoe(at: index)
        }
    }

    @MainActor
    func modifyShoe() {
        shoes.modifyShoe(shoe, at: index)
        editedName = ""
        editedMiles = ""
        editing = false
        focusedField = nil
    }
}

#Preview {
    ShoeSettingsEditView(index: 0, shoe: MylesShoe(name: "Test Shoe"))
}
