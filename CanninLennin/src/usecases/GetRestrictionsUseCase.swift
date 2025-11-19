import Foundation

//let results = try await repo.getParkingRestrictions()

struct GetRestrictionsUseCase {
    
    var resRepo: RestrictionsRepo
    var resFactory: RestrictionFactory
    var presenter: RestrictionResponseFormatter
    
    init() {
        self.resRepo = RestrictionsRepo()
        self.resFactory = RestrictionFactory()
        self.presenter = RestrictionResponseFormatter()
    }
    
    public func execute(request: RestrictionRequestModel) async throws -> [RestrictionResponseModel] {
        
        let results = try await resRepo.getParkingRestrictions()
        
        var responseList: [RestrictionResponseModel] = []
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for result in results {
            
            guard let start = formatter.date(from: result.startTime),
                  let end = formatter.date(from: result.endTime)
            else {
                continue
            }
            
            let entity = resFactory.create(
                id: result.id,
                streetName: result.streetName,
                longitude: result.longitude,
                latitude: result.latitude,
                startTime: start,
                endTime: end,
                weekdays: result.weekdays,
                description: result.description,
                hourlyRate: result.hourlyRate
            )
            
            if entity.isWithinRadius(
                lat: request.latitude,
                lng: request.longitude,
                radius: request.radius
            ) {
                responseList.append(
                    RestrictionResponseModel(
                        id: entity.id,
                        streetName: entity.streetName,
                        longitude: entity.longitude,
                        latitude: entity.latitude,
                        startTime: entity.startTime,
                        endTime: entity.endTime,
                        weekdays: entity.weekdays,
                        description: entity.description,
                        hourlyRate: entity.hourlyRate
                    )
                )
            }
        }
        
        if responseList.isEmpty {
            return presenter.prepareFailView(
                response: "No restrictions found within the specified radius."
            )
        }
        
        return presenter.prepareSuccessView(response: responseList)
    }
}
