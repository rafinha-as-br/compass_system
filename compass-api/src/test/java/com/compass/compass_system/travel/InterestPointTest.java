package com.compass.compass_system.travel;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class InterestPointTest {

    @Test
    void observationIsTrimmedAndBlankMeansNoObservation() {
        InterestPoint point = new InterestPoint();
        point.setObservation("  Levar protetor solar  ");
        assertEquals("Levar protetor solar", point.getObservation());

        point.setObservation("   ");
        assertNull(point.getObservation());

        point.setObservation(null);
        assertNull(point.getObservation());
    }

    @Test
    void observationOverTheLimitIsKeptSoTheControllerCanReject() {
        InterestPoint point = new InterestPoint();
        point.setObservation("a".repeat(InterestPoint.OBSERVATION_MAX_LENGTH + 1));

        assertEquals(InterestPoint.OBSERVATION_MAX_LENGTH + 1, point.getObservation().length());
    }
}
