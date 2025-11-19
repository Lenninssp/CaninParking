import Foundation


struct GetRestrictionsUseCase {
    private let resRepo: RestrictionsRepo
    private let resFactory: RestrictionFactory
    private let presenter: RestrictionResponseFormatter
    
    init(
        resRepo: RestrictionsRepo = RestrictionsRepo(),
        resFactory: RestrictionFactory = RestrictionFactory(),
        presenter: RestrictionResponseFormatter = RestrictionResponseFormatter()
    ) {
        self.resRepo = resRepo
        self.resFactory = resFactory
        self.presenter = presenter
    }
    
    func execute(request: RestrictionRequestModel) async throws -> [RestrictionResponseModel] {
        print("🔍 Fetching parking restrictions...")
        
        let persistenceResults = try await resRepo.getParkingRestrictions()
        print("📦 Received \(persistenceResults.count) restrictions from repository")
        
        var responseList: [RestrictionResponseModel] = []
        var failedParseCount = 0
        
        for result in persistenceResults {
            guard let entity = resFactory.createEntity(from: result) else {
                failedParseCount += 1
                continue
            }
            
            let distance = entity.calculateDistance(to: request.latitude, lng: request.longitude)
            
            if distance <= request.radius {
                let response = resFactory.createResponse(from: entity, distanceFromUser: distance)
                responseList.append(response)
            }
        }
        
        if failedParseCount > 0 {
            print("Failed to parse \(failedParseCount) restrictions")
            return presenter.prepareFailView(response: "There was an error parsint the restrictions")
        }
        
        print("Found \(responseList.count) restrictions within \(request.radius)m")
        
        if responseList.isEmpty {
            return presenter.prepareFailView(
                response: "No restrictions found within the specified radius."
            )
        }
        
        return presenter.prepareSuccessView(response: responseList)
    }
}