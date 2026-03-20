package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_BODY_TYPE_TBL")
@Getter
public class RefBodyType {

    @Id
    @Column(name = "RBT_ID")
    private Integer id;

    @Column(name = "RBT_CODE")
    private Integer code;

    @Column(name = "RBT_DESCRIPTION")
    private String description;

    @Column(name = "RBT_REQUIRES_LV_SECTION")
    private boolean requiresLvSection;
}
