//
//  PageView.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 01.09.2023.
//

import SwiftUI

struct PageView<Page: View>: View {
    let pages: [Page]
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PageViewController(pages: pages, currentPage: $currentPage)
            PageControl(numberOfPages: pages.count, currentPage: $currentPage)
                .padding(.horizontal)
        }
    }
}
