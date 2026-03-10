package gov.nhtsa.mmucc.auth.firebase;

import gov.nhtsa.mmucc.common.exception.MmuccException;

/**
 * Abstraction over the Firebase Admin SDK for authentication operations.
 * Implemented by {@link FirebaseAuthGatewayImpl} in production.
 * Replaced by a mock in tests to avoid Firebase SDK dependencies.
 */
public interface FirebaseAuthGateway {

    /**
     * Verifies a Firebase ID token (checks signature, expiry, and revocation).
     *
     * @param idToken the raw ID token from the Angular Firebase SDK
     * @return the verified claims
     * @throws MmuccException.InvalidFirebaseTokenException if the token is invalid or revoked
     */
    FirebaseTokenClaims verifyIdToken(String idToken);
}
