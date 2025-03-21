import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateTodo())

    app.views.use(.leaf)

    // Register routes
    try routes(app)

    // Добавляем конфигурацию для прослушивания всех интерфейсов
    app.http.server.configuration.address = .hostname("0.0.0.0", port: 8080)

    // Обработка webhook-запросов от Telegram
    app.post("webhook") { req -> HTTPStatus in
        // Декодируем данные, полученные от Telegram
        let update = try req.content.decode(Update.self) // Здесь Update — это структура для данных Telegram

        // Ты можешь обработать входящие сообщения в этой части
        app.logger.info("Получено обновление: \(update)")

        // Возвращаем успешный ответ
        return .ok
    }
}

struct Update: Content {
    var update_id: Int
    var message: Message
}

struct Message: Content {
    var message_id: Int
    var from: User
    var chat: Chat
    var text: String?
}

struct User: Content {
    var id: Int
    var first_name: String
    var last_name: String?
    var username: String?
}

struct Chat: Content {
    var id: Int
    var first_name: String?
    var last_name: String?
    var username: String?
    var type: String
}
