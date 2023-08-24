//
//  FavouritesTab.swift
//  WeatherApp-iOS
//
//  Created by Alex Motoc on 24.08.2023.
//

import SwiftUI

struct FavouritesTab: UIViewControllerRepresentable {
    
    let viewModel: FavouritesListViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = FavouritesListViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}

struct FavouritesTab_Previews: PreviewProvider {
    static var previews: some View {
        FavouritesTab(viewModel: .init(store: WeatherInformationStore(), useCase: MockFavouriteLocationUseCase(), appSettings: .init()))
    }
}
