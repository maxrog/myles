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
    
    @State var newShoeName: String = ""
        
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Array(shoes.shoes.enumerated()), id: \.element) { index, shoe in
                        ShoeSettingsEditView(index: index, shoe: shoe)
                    }
                }
                Section {
                    TextField("Add Shoe", text: $newShoeName)
                        .lineLimit(1)
                        .font(.custom("norwester", size: 16))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                }
                .onSubmit(addNewShoe)
            }
            .navigationTitle("Shoes")
        }
    }
    
    private func addNewShoe() {
        guard !newShoeName.isEmpty else { return }
        withAnimation {
            shoes.addShoe(MylesShoe(name: newShoeName))
            newShoeName = ""
        }
    }

}

#Preview {
    ShoesSettingsView()
}
