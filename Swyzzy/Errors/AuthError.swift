

/// Ошибки, возникающие при авторизации
enum AuthError: Error {
    
    // Определенное сообщение, которое необходимо вывести
    case message(String)
    
    /// Текстовое поле не заполнено
    case phoneFieldIsEmpty
    
    /// Не хватает данных для авторизации
    case haveNotCredentials
    
}
