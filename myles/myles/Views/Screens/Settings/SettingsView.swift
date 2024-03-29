//
//  SettingsView.swift
//  myles
//
//  Created by Max Rogers on 12/8/23.
//

import SwiftUI

/// TODO: View Model
/// TODO: toggle for showing / hiding streak & minimum streak mileage per day
/// TODO: mi/km preference + date format (24H option)


/// A settings view for various app settings / user preferences
struct SettingsView: View {
    
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var goals: GoalsManager

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .frame(width: 35, height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.blue)
                            )
                        Stepper(onIncrement: {
                            goals.updateWeeklyMileageGoal(to: goals.weeklyMileageGoal + 1)
                        }, onDecrement: {
                            goals.updateWeeklyMileageGoal(to: goals.weeklyMileageGoal - 1)
                        }, label: {
                            HStack {
                                Text("Weekly Mileage:")
                                Text("\(goals.weeklyMileageGoal)")
                                    .fontWeight(.bold)
                            }
                        })
                    }
                    .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                } header: {
                    Text("Goals")
                }
                .headerProminence(.increased)
                Section {
                    NavigationLink {
                        ShoesSettingsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "shoe")
                                .frame(width: 35, height: 35)
                                .background(
                                 RoundedRectangle(cornerRadius: 8)
                                    .foregroundStyle(Color.blue)
                                )
                            Text("Shoes")
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                    }
                } header: {
                    Text("App")
                }
                .headerProminence(.increased)
                Section {
                    if !theme.useSystemSetting {
                        Toggle(isOn: $theme.applyDarkMode) {
                            Text("Dark Mode")
                        }
                    }
                    Toggle(isOn: $theme.useSystemSetting.animation()) {
                        Text("Use Device Settings")
                    }
                    ColorPicker(selection: $theme.accentColor, supportsOpacity: false) {
                        Text("Tint")
                    }
                } header: {
                    Text("Theme")
                } footer: {
                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(theme.accentColor)
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
