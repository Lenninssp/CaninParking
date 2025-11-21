import Foundation

struct RestrictionResponseFormatter {
    func prepareSuccessView(response: [RestrictionResponseModel]) -> [RestrictionResponseModel] {
        return response.sorted { $0.distanceFromUser < $1.distanceFromUser }
    }
    
    func prepareFailView(response: String) -> [RestrictionResponseModel] {
        print("There was an error:  \(response)")
        return []
    }
}