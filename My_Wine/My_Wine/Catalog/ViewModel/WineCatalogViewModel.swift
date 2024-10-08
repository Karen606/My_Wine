//
//  WineCatalogViewModel.swift
//  My_Wine
//
//  Created by Karen Khachatryan on 07.10.24.
//

import Foundation

class WineCatalogViewModel {
    static let shared = WineCatalogViewModel()
    @Published var filteredWine: [WineModel] = []
    @Published var filterWine = Filter()
    var wine: [WineModel] = []
    var search: String?

    private init() {}
    
    func fetchData() {
        CoreDataManager.shared.fetchWine { [weak self] wineModel, error in
            guard let self = self else { return }
            self.wine = wineModel
            self.filteredWine = wineModel
            self.filter(by: search)
        }
    }
    
    func updateMyWineStatus(id: UUID, isMyWine: Bool, completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.updateMyWineStatus(wineID: id, isMyWine: isMyWine) { error in
            completion(error)
        }
    }
    
    func updateFavoritesStatus(id: UUID, isFavorite: Bool, completion: @escaping (Error?) -> Void) {
        CoreDataManager.shared.updateWineFavoriteStatus(wineID: id, isFavorite: isFavorite) { error in
            completion(error)
        }
    }
    
    func filter() {
        filteredWine = wine.filter { wine in
            let matchesGrape = filterWine.filterRating == nil || wine.rating == filterWine.filterRating
            let matchesYear = filterWine.filterYear == nil || wine.year == filterWine.filterYear
            let matchesCountry = filterWine.filterCountry == nil || wine.country?.lowercased() == filterWine.filterCountry?.lowercased()
            return matchesGrape && matchesYear && matchesCountry
        }
        if let value = search, !value.isEmpty {
            filteredWine = filteredWine.filter { ($0.name)?.localizedCaseInsensitiveContains(value) ?? false }
        }
    }
    
    func filterByType(filterType: FilterType, value: String?) {
        switch filterType {
        case .country:
            filterWine.filterCountry = value
            filter()
        case .rating:
            filterWine.filterRating = Double(value ?? "")
            filter()
        case .year:
            filterWine.filterYear = value
            filter()
        }
    }
    
    func filter(by value: String?) {
        self.search = value
        filter()
        if let value = value, !value.isEmpty {
            filteredWine = filteredWine.filter { ($0.name)?.localizedCaseInsensitiveContains(value) ?? false }
        }
    }
    
    func resetAllFilter() {
        filterWine.filterRating = nil
        filterWine.filterCountry = nil
        filterWine.filterYear = nil
        self.filteredWine = wine
        filter(by: search)
    }
    
}
