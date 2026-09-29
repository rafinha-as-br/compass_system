package com.compass.compass_system.places;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class NominatimRateLimiterTest {

    // reserveSlot() só calcula o espaçamento, sem dormir de verdade — permite
    // testar a lógica de forma determinística e instantânea.

    @Test
    void firstCallInAnIdleWindowNeedsNoWait() {
        NominatimRateLimiter rateLimiter = new NominatimRateLimiter(1000);
        assertThat(rateLimiter.reserveSlot(10_000)).isZero();
    }

    @Test
    void secondCallRightAfterMustWaitOutTheFullInterval() {
        NominatimRateLimiter rateLimiter = new NominatimRateLimiter(1000);

        rateLimiter.reserveSlot(10_000);
        long secondWait = rateLimiter.reserveSlot(10_000);

        assertThat(secondWait).isEqualTo(1000);
    }

    @Test
    void callArrivingAfterTheIntervalHasAlreadyPassedNeedsNoWait() {
        NominatimRateLimiter rateLimiter = new NominatimRateLimiter(1000);

        rateLimiter.reserveSlot(10_000);
        long laterWait = rateLimiter.reserveSlot(12_000);

        assertThat(laterWait).isZero();
    }
}
