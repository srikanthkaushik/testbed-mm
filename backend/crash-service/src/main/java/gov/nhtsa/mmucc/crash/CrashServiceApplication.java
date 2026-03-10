package gov.nhtsa.mmucc.crash;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication(scanBasePackages = "gov.nhtsa.mmucc")
@ConfigurationPropertiesScan
public class CrashServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(CrashServiceApplication.class, args);
    }
}
