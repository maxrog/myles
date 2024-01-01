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
    
    @StateObject var viewModel: RecapViewModel
    
    @State var selectedShoe: MylesShoe?
    @State var newShoe: String = ""
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedShoe) {
                Section {
                    ForEach(Array(shoes.shoes.enumerated()), id: \.element) { index, shoe in
                        HStack(alignment: .center) {
                            VStack(alignment: .leading) {
                                Text(shoe.name)
                                    .font(.custom("norwester", size: 22))
                                Text("\(shoe.miles.prettyString) miles")
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
                                if let existingSelection = selectedShoe {
                                    shoes.removeShoe(existingSelection, from: viewModel.run)
                                }
                                shoes.addShoeToRun(shoe, run: viewModel.run)
                                selectedShoe = shoe
                            } else {
                                shoes.removeShoe(shoe, from: viewModel.run)
                                selectedShoe = nil
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                // TODO confirmation alert to delete
                                deleteShoe(at: index)
                            } label: {
                                Image(systemName: "delete.backward.fill")
                                    .foregroundStyle(Color.red)
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
    
    private func deleteShoe(at index: Int) {
        withAnimation {
            shoes.deleteShoe(at: index)
        }
    }
}

#Preview {
    ShoePickerView(viewModel: RecapViewModel(health: HealthManager(), run: MylesRun.testRun))
}
