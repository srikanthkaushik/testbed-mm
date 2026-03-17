package gov.nhtsa.mmucc.crash.exception;

import gov.nhtsa.mmucc.crash.dto.FieldError;

import java.util.List;

/** Thrown when MMUCC business-rule validation fails. Maps to HTTP 422. */
public class ValidationException extends RuntimeException {

    private final List<FieldError> errors;

    public ValidationException(List<FieldError> errors) {
        super("MMUCC validation failed: " + errors.size() + " error(s)");
        this.errors = errors;
    }

    public List<FieldError> getErrors() {
        return errors;
    }
}
