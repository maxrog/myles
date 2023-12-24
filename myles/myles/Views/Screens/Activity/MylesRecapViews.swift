//
//  MylesRecapViews.swift
//  myles
//
//  Created by Max Rogers on 12/18/23.
//

import SwiftUI

// TODO expand tap sometimes choppy 

/// An accessory view for showing group of run recap metrics
struct MylesRecapView: View {
    
    @StateObject var viewModel: MylesRecapViewModel
    
    var body: some View {
        VStack() {
            MylesRecapMileageView(run: viewModel.run)
            if viewModel.expanded {
                if viewModel.showMap {
                    MylesMapView(viewModel: MapViewModel(run: viewModel.run))
                    // TODO should be a ratio from width so all screens look good
                        .frame(height: 240)
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(.horizontal, 16)
                } else {
                    MylesHeartView()
                    // TODO should be a ratio from width so all screens look good
                        .frame(height: 80)
                }
            }
            MylesRecapBarView(viewModel: viewModel)
            if viewModel.run.environment == .outdoor, viewModel.expanded {
                MylesMarqueeText(text: viewModel.run.mileSplitStrings.joined(separator: "     "),
                                 font: UIFont(name: "norwester", size: 13) ?? UIFont.systemFont(ofSize: 13))
            }
        }
        .padding(.top, 8)
        .padding(.bottom, viewModel.run.environment == .outdoor && viewModel.expanded ? 2 : 8)
        .frame(maxWidth: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            Task {
                await viewModel.downloadMap()
            }
        }
    }
}

#Preview {
    let viewModel = MylesRecapViewModel(run: MylesRun.testRun)
    viewModel.expanded = true
    return MylesRecapView(viewModel: viewModel)
}

// MARK: Accessory Views

/// Recap header view containing run date and duration information
struct MylesRecapHeaderView: View {
    
    @StateObject var run: MylesRun
    
    var body: some View {
        HStack {
            Text(run.startTime.shortDayOfWeekDateFormat + "." + run.startTime.shortCalendarDateFormat)
                .font(.custom("norwester", size: 18))
            Text("|")
                .font(.custom("norwester", size: 16))
            Text("\(run.duration.prettyTimeString)")
                .font(.custom("norwester", size: 18))
        }
    }
}

/// Recap view containing run mileage
struct MylesRecapMileageView: View {
    
    @StateObject var run: MylesRun
    
    var body: some View {
        Text("\(run.distance.prettyString) mi")
            .font(.custom("norwester", size: 28))
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color(.systemGray4))
            )
    }
}

/// Recap view containing run accessory data including pace, heart rate, elevation, and temp
struct MylesRecapBarView : View {
    
    @StateObject var viewModel: MylesRecapViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if let heartRate = viewModel.run.averageHeartRateBPM, heartRate > 0 {
                    Label("\(heartRate)", systemImage: "heart")
                        .font(.custom("norwester", size: 13))
                        .labelStyle(MylesIconLabel())
                }
            }.frame(maxWidth: .infinity)
            
            Label("\(viewModel.run.averageMilePaceString)/mi", systemImage: "stopwatch")
                .font(.custom("norwester", size: 15))
                .labelStyle(MylesIconLabel())
                .fixedSize()
            
            VStack {
                if let elevation = viewModel.run.elevationChange.gain, elevation > 0 {
                    Label("\(elevation) ft", systemImage: "arrow.up.forward")
                        .font(.custom("norwester", size: 13))
                        .labelStyle(MylesIconLabel())
                }
            }.frame(maxWidth: .infinity)
            Spacer()
        }
    }
}
