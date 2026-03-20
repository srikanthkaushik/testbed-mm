package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_SURFACE_CONDITION_TBL")
@Getter
public class RefSurfaceCondition {

    @Id
    @Column(name = "RSC_ID")
    private Integer id;

    @Column(name = "RSC_CODE")
    private Integer code;

    @Column(name = "RSC_DESCRIPTION")
    private String description;
}
