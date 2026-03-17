package gov.nhtsa.mmucc.crash.dto;

/** A single field-level validation error returned in a 422 response body. */
public record FieldError(String field, String message) {}
