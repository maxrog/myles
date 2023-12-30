//
//  HeartView.swift
//  myles
//
//  Created by Max Rogers on 12/21/23.
//

import SwiftUI

/*
 TODO - support parameters, background color / corner radius / size tc
 */

/// Wrapper view for displaying heart
struct HeartView: View {
    
    var body: some View {
        Image(uiImage: UIImage(named: "mylesHeart") ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            .background(Color(.systemGray4))
            .cornerRadius(8)
    }
    
}

#Preview {
    HeartView()
}
