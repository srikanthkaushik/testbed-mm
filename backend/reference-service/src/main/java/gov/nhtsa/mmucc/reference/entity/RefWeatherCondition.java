package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_WEATHER_CONDITION_TBL")
@Getter
public class RefWeatherCondition {

    @Id
    @Column(name = "RWC_ID")
    private Integer id;

    @Column(name = "RWC_CODE")
    private Integer code;

    @Column(name = "RWC_DESCRIPTION")
    private String description;
}
