package gov.nhtsa.mmucc.auth.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

@Configuration
@Profile("!test")  // Firebase SDK initialization is skipped in tests; FirebaseAuthGateway is mocked
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    @Value("${firebase.service-account-path}")
    private String serviceAccountPath;

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            log.info("FirebaseApp already initialized, reusing existing instance");
            return FirebaseApp.getInstance();
        }

        InputStream serviceAccount;
        if (serviceAccountPath.startsWith("classpath:")) {
            String classpathResource = serviceAccountPath.substring("classpath:".length());
            serviceAccount = getClass().getClassLoader().getResourceAsStream(classpathResource);
            if (serviceAccount == null) {
                throw new IllegalStateException(
                        "Firebase service account not found on classpath: " + classpathResource);
            }
        } else {
            serviceAccount = new FileInputStream(serviceAccountPath);
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .build();

        FirebaseApp app = FirebaseApp.initializeApp(options);
        log.info("Firebase Admin SDK initialized successfully");
        return app;
    }
}
