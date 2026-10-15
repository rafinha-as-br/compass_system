package com.compass.compass_system.company;

import com.compass.compass_system.exceptions.BusinessException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/** Regras puras do módulo company (sem Spring): geração do local-part e domínio. */
class CompanyServiceTest {

    @Test
    void localPartRemovesAccentsLowercasesAndTurnsSpacesIntoDots() {
        assertEquals("ana.paula.ribeiro", CompanyService.toLocalPart("Ana Paula Ribeiro"));
        assertEquals("joao.cesar", CompanyService.toLocalPart("João César"));
        assertEquals("maria.jose", CompanyService.toLocalPart("  Maria   José  "));
    }

    @Test
    void localPartDropsCharactersOutsideTheAllowedSet() {
        assertEquals("ana.oconnor", CompanyService.toLocalPart("Ana O'Connor"));
        assertEquals("luiz.silva", CompanyService.toLocalPart("Luiz-Silva"));
        assertEquals("agente.2", CompanyService.toLocalPart("Agente #2"));
    }

    @Test
    void localPartCollapsesDotsAndTrimsThem() {
        assertEquals("ana.paula", CompanyService.toLocalPart(". Ana . Paula ."));
    }

    @Test
    void localPartRejectsNamesThatProduceNothing() {
        assertThrows(BusinessException.class, () -> CompanyService.toLocalPart("   "));
        assertThrows(BusinessException.class, () -> CompanyService.toLocalPart("@#$"));
        assertThrows(BusinessException.class, () -> CompanyService.toLocalPart(null));
    }

    @Test
    void domainIsNormalizedToLowercaseWithoutAt() {
        assertEquals("aurora.com.br", CompanyService.normalizeDomain(" @Aurora.COM.br "));
    }

    @Test
    void domainRejectsInvalidValues() {
        assertThrows(BusinessException.class, () -> CompanyService.normalizeDomain(null));
        assertThrows(BusinessException.class, () -> CompanyService.normalizeDomain("aurora"));
        assertThrows(BusinessException.class, () -> CompanyService.normalizeDomain("a@aurora.com"));
        assertThrows(BusinessException.class, () -> CompanyService.normalizeDomain("aurora .com"));
    }

    @Test
    void loginMatchesDomainComparesOnlyTheSuffixCaseInsensitively() {
        assertTrue(CompanyService.loginMatchesDomain("ana@Aurora.com.br", "aurora.com.br"));
        assertFalse(CompanyService.loginMatchesDomain("ana@outra.com.br", "aurora.com.br"));
        assertFalse(CompanyService.loginMatchesDomain("ana", "aurora.com.br"));
        assertFalse(CompanyService.loginMatchesDomain(null, "aurora.com.br"));
    }
}
