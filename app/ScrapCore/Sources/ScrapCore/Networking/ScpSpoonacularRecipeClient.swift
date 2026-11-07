import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A thin client for the Spoonacular API. Every failure is mapped onto
/// ``ScpError`` here, so nothing above this type sees a raw network error
/// or a DTO (REQ-D-18, REQ-D-22).
public struct ScpSpoonacularRecipeClient: Sendable {
    private let apiKey: String
    private let transport: any ScpHTTPTransport

    /// Creates a client using the key in `config`.
    public init(config: ScpConfig, transport: any ScpHTTPTransport = ScpURLSessionTransport()) {
        self.apiKey = config.spoonacularAPIKey
        self.transport = transport
    }

    /// Recipes that use as many of `ingredientNames` as possible. Returns an
    /// empty array, without calling the network, when no names are given.
    public func searchByIngredients(_ ingredientNames: [String], maxResults: Int = 20) async throws -> [ScpRecipe] {
        guard !ingredientNames.isEmpty else { return [] }

        let results = try await fetch(
            [ScpSpoonacularRecipeDTO].self,
            path: ScpSpoonacularEndpoint.searchByIngredients,
            query: [
                URLQueryItem(name: "ingredients", value: ingredientNames.joined(separator: ",")),
                URLQueryItem(name: "number", value: String(maxResults)),
                URLQueryItem(name: "ranking", value: "2"),
                URLQueryItem(name: "ignorePantry", value: "true"),
            ]
        )
        return results.compactMap { $0.toRecipe() }
    }

    /// The full recipe, with instructions, for a Spoonacular recipe `id`.
    public func recipe(id: String) async throws -> ScpRecipe {
        let detail = try await fetch(
            ScpSpoonacularRecipeDetailDTO.self,
            path: ScpSpoonacularEndpoint.path(ScpSpoonacularEndpoint.recipeInformation, id: id),
            query: [URLQueryItem(name: "includeNutrition", value: "false")]
        )
        guard let recipe = detail.toRecipe() else { throw ScpError.invalidData }
        return recipe
    }

    /// Ingredient suggestions for what the user has typed so far. Returns an empty
    /// array, without calling the network, for a blank query.
    public func autocompleteIngredients(_ query: String, maxResults: Int = 6) async throws -> [ScpIngredient] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let results = try await fetch(
            [ScpSpoonacularIngredientDTO].self,
            path: ScpSpoonacularEndpoint.ingredientAutocomplete,
            query: [
                URLQueryItem(name: "query", value: trimmed),
                URLQueryItem(name: "number", value: String(maxResults)),
            ]
        )
        return results.compactMap { $0.toIngredient() }
    }

    private func fetch<Response: Decodable>(
        _ type: Response.Type,
        path: String,
        query: [URLQueryItem]
    ) async throws -> Response {
        var components = URLComponents()
        components.scheme = "https"
        components.host = ScpSpoonacularEndpoint.host
        components.path = path
        components.queryItems = query + [URLQueryItem(name: "apiKey", value: apiKey)]
        guard let url = components.url else { throw ScpError.invalidInput }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await transport.data(for: URLRequest(url: url))
        } catch {
            throw ScpError.network
        }

        guard let http = response as? HTTPURLResponse else { throw ScpError.network }
        switch http.statusCode {
        case 200..<300: break
        case 401, 403: throw ScpError.unauthorized
        case 402, 429: throw ScpError.rateLimited
        case 404: throw ScpError.notFound
        default: throw ScpError.network
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw ScpError.invalidData
        }
    }
}
