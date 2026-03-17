package gov.nhtsa.mmucc.crash.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

/**
 * Crash-service-specific exception handlers.
 * General handlers (400/401/403/404/500) are provided by common GlobalExceptionHandler.
 */
@RestControllerAdvice
public class CrashExceptionHandler {

    /** MMUCC business-rule failures → 422 Unprocessable Entity */
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(ValidationException ex) {
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY)
                .body(Map.of(
                        "status",  422,
                        "error",   "Validation Failed",
                        "errors",  ex.getErrors()));
    }

    /** JPA entity not found → 404 */
    @ExceptionHandler(jakarta.persistence.EntityNotFoundException.class)
    public ResponseEntity<Map<String, Object>> handleNotFound(jakarta.persistence.EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(Map.of(
                        "status",  404,
                        "error",   "Not Found",
                        "message", ex.getMessage() != null ? ex.getMessage() : "Resource not found"));
    }
}
