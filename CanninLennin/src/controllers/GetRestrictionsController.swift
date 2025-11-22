import Foundation

struct GetRestrictionsController {
    let useCase: GetRestrictionsUseCase
    
    init() {
        self.useCase = GetRestrictionsUseCase()
    }
    
    public func POST(request: RestrictionRequestModel) async throws -> [RestrictionResponseModel] {
        return try await useCase.execute(request: request)
    }
}
