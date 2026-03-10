package gov.nhtsa.mmucc.common.dto;

import java.time.Instant;
import java.util.List;

/**
 * Standard error response body returned by all services.
 */
public record ErrorResponse(
        int status,
        String error,
        String message,
        String path,
        Instant timestamp,
        List<FieldError> fieldErrors
) {
    /**
     * Convenience factory for non-validation errors (no field errors).
     */
    public static ErrorResponse of(int status, String error, String message, String path) {
        return new ErrorResponse(status, error, message, path, Instant.now(), List.of());
    }

    public record FieldError(String field, String message) {}
}
