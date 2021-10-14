

/// Ошибки, возникающие при авторизации
enum AuthError: Error {
    
    // Определенное сообщенеи, которое необходимо вывести
    case message(String)
    
    /// Текстовое поле не заполнено
    case phoneFieldIsEmpty
    
    /// Не хватает данных для авторизации
    case haveNotCredentials
    
}
