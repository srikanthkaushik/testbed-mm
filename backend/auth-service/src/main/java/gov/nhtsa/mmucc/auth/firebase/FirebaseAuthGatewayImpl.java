package gov.nhtsa.mmucc.auth.firebase;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!test")
public class FirebaseAuthGatewayImpl implements FirebaseAuthGateway {

    @Override
    public FirebaseTokenClaims verifyIdToken(String idToken) {
        try {
            // checkRevoked=true: immediately reject sessions revoked from Firebase Console
            FirebaseToken token = FirebaseAuth.getInstance().verifyIdToken(idToken, true);

            return new FirebaseTokenClaims(
                    token.getUid(),
                    token.getEmail(),
                    token.getName(),
                    token.isEmailVerified()
            );
        } catch (FirebaseAuthException e) {
            throw new MmuccException.InvalidFirebaseTokenException(
                    e.getAuthErrorCode() != null ? e.getAuthErrorCode().name() : e.getMessage(),
                    e
            );
        }
    }
}
