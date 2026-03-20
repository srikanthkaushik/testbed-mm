package gov.nhtsa.mmucc.reference.entity;

import jakarta.persistence.*;
import lombok.Getter;

@Entity
@Table(name = "REF_INJURY_STATUS_TBL")
@Getter
public class RefInjuryStatus {

    @Id
    @Column(name = "RIS_ID")
    private Integer id;

    @Column(name = "RIS_CODE")
    private Integer code;

    @Column(name = "RIS_DESCRIPTION")
    private String description;

    @Column(name = "RIS_KABCO_LETTER")
    private String kabcoLetter;

    @Column(name = "RIS_REQUIRES_FATAL_SECTION")
    private boolean requiresFatalSection;
}
