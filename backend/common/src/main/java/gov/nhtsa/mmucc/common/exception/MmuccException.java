package gov.nhtsa.mmucc.common.exception;

import org.springframework.http.HttpStatus;

/**
 * Base runtime exception for all application-level errors.
 * Subclasses declare a fixed HTTP status; the GlobalExceptionHandler maps them.
 */
public class MmuccException extends RuntimeException {

    private final HttpStatus status;

    public MmuccException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public MmuccException(HttpStatus status, String message, Throwable cause) {
        super(message, cause);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }

    // -----------------------------------------------------------------------
    // Concrete subtypes
    // -----------------------------------------------------------------------

    public static class UserNotFoundException extends MmuccException {
        public UserNotFoundException(String identifier) {
            super(HttpStatus.NOT_FOUND, "User not found: " + identifier);
        }
    }

    public static class UserAlreadyExistsException extends MmuccException {
        public UserAlreadyExistsException(String field, String value) {
            super(HttpStatus.CONFLICT, "User already exists with " + field + ": " + value);
        }
    }

    public static class AccountDisabledException extends MmuccException {
        public AccountDisabledException() {
            super(HttpStatus.FORBIDDEN, "Account is disabled");
        }
    }

    public static class AccountLockedException extends MmuccException {
        public AccountLockedException() {
            super(HttpStatus.FORBIDDEN, "Account is locked due to too many failed login attempts");
        }
    }

    public static class InvalidFirebaseTokenException extends MmuccException {
        public InvalidFirebaseTokenException(String reason) {
            super(HttpStatus.UNAUTHORIZED, "Invalid Firebase token: " + reason);
        }

        public InvalidFirebaseTokenException(String reason, Throwable cause) {
            super(HttpStatus.UNAUTHORIZED, "Invalid Firebase token: " + reason, cause);
        }
    }

    public static class RefreshTokenExpiredException extends MmuccException {
        public RefreshTokenExpiredException() {
            super(HttpStatus.UNAUTHORIZED, "Refresh token has expired or is invalid");
        }
    }
}
