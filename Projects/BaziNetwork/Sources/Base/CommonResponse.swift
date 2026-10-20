// Copyright © 2026 ChungBazi. All rights reserved.

public struct CommonResponse<T: Decodable>: Decodable {
    public let isSuccess: Bool
    public let code: String
    public let message: String
    public let result: T
}
