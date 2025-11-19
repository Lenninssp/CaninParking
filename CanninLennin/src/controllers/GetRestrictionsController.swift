import Foundation

struct GetRestrictionsController {
    var useCase: GetRestrictionsUseCase
    
    init() {
        self.useCase = GetRestrictionsUseCase()
    }
    
    public func POST(request: RestrictionRequestModel) async throws -> [RestrictionResponseModel] {
        return try await useCase.execute(request: request)
    }
}
