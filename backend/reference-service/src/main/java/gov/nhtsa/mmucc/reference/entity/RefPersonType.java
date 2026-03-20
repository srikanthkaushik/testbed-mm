package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_PERSON_TYPE_TBL")
@Getter
public class RefPersonType {

    @Id
    @Column(name = "RPT_ID")
    private Integer id;

    @Column(name = "RPT_CODE")
    private Integer code;

    @Column(name = "RPT_DESCRIPTION")
    private String description;

    @Column(name = "RPT_IS_NON_MOTORIST")
    private boolean isNonMotorist;
}
