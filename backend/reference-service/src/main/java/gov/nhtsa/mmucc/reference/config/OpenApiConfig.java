package gov.nhtsa.mmucc.reference.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("MMUCC Reference Service API")
                        .description("Read-only lookup data for all MMUCC 5th Edition coded-value fields")
                        .version("1.0.0"));
    }
}
