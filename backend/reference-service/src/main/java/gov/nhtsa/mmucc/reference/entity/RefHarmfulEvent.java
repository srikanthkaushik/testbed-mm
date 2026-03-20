package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_HARMFUL_EVENT_TBL")
@Getter
public class RefHarmfulEvent {

    @Id
    @Column(name = "RHE_ID")
    private Integer id;

    @Column(name = "RHE_CODE")
    private Integer code;

    @Column(name = "RHE_DESCRIPTION")
    private String description;

    @Column(name = "RHE_CATEGORY")
    private String category;
}
