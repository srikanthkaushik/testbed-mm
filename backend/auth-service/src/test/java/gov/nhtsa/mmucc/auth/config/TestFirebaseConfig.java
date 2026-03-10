package gov.nhtsa.mmucc.auth.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

/**
 * Replaces FirebaseConfig during tests to prevent any attempt to read a
 * real service account file. FirebaseAuthGateway is mocked with @MockBean
 * in each test class, so no FirebaseApp bean is needed.
 */
@TestConfiguration
public class TestFirebaseConfig {

    /**
     * A no-op FirebaseApp substitute is not needed because FirebaseAuthGatewayImpl
     * is never loaded in tests — @MockBean FirebaseAuthGateway replaces the whole
     * interface. This config simply prevents the real FirebaseConfig from running.
     */
    @Bean
    @Primary
    public String firebaseDisabled() {
        return "firebase-disabled-in-tests";
    }
}
