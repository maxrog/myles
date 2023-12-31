//
//  ShoePickerView.swift
//  myles
//
//  Created by Max Rogers on 12/30/23.
//

import SwiftUI

/// Shoe picker that manages shoe selection for a specific run
struct ShoePickerView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var shoes: ShoeManager
    
    @State var selectedShoe: MylesShoe?
    @State var newShoe: String = ""
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedShoe) {
                Section {
                    ForEach(shoes.shoes) { shoe in
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text(shoe.name)
                                    .font(.custom("norwester", size: 22))
                                Text("\(shoe.miles) miles")
                                    .font(.custom("norwester", size: 14))
                                    .foregroundColor(Color(.systemGray2))
                            }
                            Spacer()
                            Image(systemName: selectedShoe == shoe ? "checkmark.square.fill" : "square")
                                .foregroundStyle(theme.accentColor)
                            Spacer()
                                .frame(width: 16)
                        }
                        .contentTransition(.symbolEffect(.replace))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedShoe != shoe {
                                selectedShoe = shoe
                            } else {
                                selectedShoe = nil
                            }
                        }
                    }
                }
                Section {
                    TextField("New Shoe", text: $newShoe)
                        .font(.custom("norwester", size: 16))
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
            shoes.addShoe(MylesShoe(name: newShoe))
            newShoe = ""
        }
    }
}

#Preview {
    ShoePickerView()
}
