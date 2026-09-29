package com.compass.compass_system.places;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicLong;

/**
 * Garante no máximo 1 chamada ao Nominatim por segundo, globalmente,
 * respeitando a política de uso do serviço público — controlar isso em um
 * lugar só é o motivo da fachada existir.
 *
 * ponytail: gate em memória do processo — vale para uma instância do
 * compass-api. Se o serviço escalar horizontalmente, o limite passa a ser
 * por instância; promover para um limitador distribuído (ex.: Redis) nesse
 * caso.
 */
@Component
public class NominatimRateLimiter {

    private final long minIntervalMs;
    private final AtomicLong nextSlotStart = new AtomicLong(0);

    public NominatimRateLimiter(@Value("${app.nominatim.min-interval-ms}") long minIntervalMs) {
        this.minIntervalMs = minIntervalMs;
    }

    public void awaitTurn() {
        long waitMs = reserveSlot(System.currentTimeMillis());
        if (waitMs > 0) {
            try {
                Thread.sleep(waitMs);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    /**
     * Reserva o próximo horário disponível e devolve quanto o chamador
     * precisa esperar, sem de fato dormir — separado de {@link #awaitTurn()}
     * para poder testar o espaçamento sem gastar tempo real de teste.
     */
    long reserveSlot(long now) {
        long assignedStart = nextSlotStart.accumulateAndGet(now, (prevSlot, n) -> Math.max(prevSlot, n) + minIntervalMs) - minIntervalMs;
        return assignedStart - now;
    }
}
