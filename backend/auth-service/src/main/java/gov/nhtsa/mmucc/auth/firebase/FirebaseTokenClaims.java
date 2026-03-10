package gov.nhtsa.mmucc.auth.firebase;

/**
 * Lightweight DTO carrying the claims extracted from a verified Firebase ID token.
 * Decouples the service layer from the Firebase Admin SDK type system.
 */
public record FirebaseTokenClaims(
        String uid,
        String email,
        String name,
        boolean emailVerified
) {}
