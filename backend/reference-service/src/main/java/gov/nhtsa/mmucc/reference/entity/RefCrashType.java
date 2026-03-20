package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_CRASH_TYPE_TBL")
@Getter
public class RefCrashType {

    @Id
    @Column(name = "RCT_ID")
    private Integer id;

    @Column(name = "RCT_CODE")
    private Integer code;

    @Column(name = "RCT_DESCRIPTION")
    private String description;
}
