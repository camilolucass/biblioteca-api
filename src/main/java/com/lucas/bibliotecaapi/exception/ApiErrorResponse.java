package com.lucas.bibliotecaapi.exception;

import java.time.LocalDateTime;
import java.util.Map;

public record ApiErrorResponse(
        LocalDateTime timestamp,
        int status,
        String error,
        String message,
        String path,
        Map<String, String> fields
) {
    public static ApiErrorResponse of(
            int status,
            String error,
            String message,
            String path,
            Map<String, String> fields
    ) {
        return new ApiErrorResponse(LocalDateTime.now(), status, error, message, path, fields);
    }
}
