import Foundation

struct RestrictionResponseFormatter {
    public func prepareSuccessView(response: [RestrictionResponseModel]) -> [RestrictionResponseModel]{
        return response;
    }
    public func prepareFailView(response: String) -> [RestrictionResponseModel] {
        return [RestrictionResponseModel(message: response)]
    }
}

