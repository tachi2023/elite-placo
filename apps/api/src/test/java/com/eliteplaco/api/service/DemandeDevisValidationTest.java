package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.DemandeDevisDTO;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DemandeDevisValidationTest {
    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void nomTelephoneEtTravauxSontObligatoires() {
        DemandeDevisDTO dto = new DemandeDevisDTO(null, "", "email-invalide", "", null, "", null, null, null, null, null, null);
        assertFalse(validator.validate(dto).isEmpty());
    }

    @Test
    void demandeValideAvecEmailFacultatif() {
        DemandeDevisDTO dto = new DemandeDevisDTO(null, "Client Test", null, "+237600000000", "Douala", "Platrerie", null, null, null, null, null, null);
        assertTrue(validator.validate(dto).isEmpty());
    }
}
