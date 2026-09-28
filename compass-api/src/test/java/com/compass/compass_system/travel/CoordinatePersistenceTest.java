package com.compass.compass_system.travel;

import com.compass.compass_system.geo.Coordinate;
import com.compass.compass_system.itinerary.Hosting;
import com.compass.compass_system.transport.Airplane;
import com.compass.compass_system.transport.Bus;
import com.compass.compass_system.transport.RentalCar;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * CPS-153: latitude/longitude persistidas junto com as entidades de local,
 * de forma nulável — registro sem coordenada (base legada) não pode quebrar.
 */
@DataJpaTest
class CoordinatePersistenceTest {

    @Autowired
    private jakarta.persistence.EntityManager entityManager;

    @Test
    void routePlanPersistsBothStartAndDestinationCoordinatesIndependently() {
        RoutePlan routePlan = new RoutePlan();
        routePlan.setStartLocation("Sao Paulo");
        routePlan.setDestination("Lisbon");
        routePlan.setStartLocationCoordinate(new Coordinate(-23.5505, -46.6333));
        routePlan.setDestinationCoordinate(new Coordinate(38.7223, -9.1393));

        entityManager.persist(routePlan);
        entityManager.flush();
        entityManager.clear();

        RoutePlan reloaded = entityManager.find(RoutePlan.class, routePlan.getId());
        assertThat(reloaded.getStartLocationCoordinate().getLatitude()).isEqualTo(-23.5505);
        assertThat(reloaded.getStartLocationCoordinate().getLongitude()).isEqualTo(-46.6333);
        assertThat(reloaded.getDestinationCoordinate().getLatitude()).isEqualTo(38.7223);
        assertThat(reloaded.getDestinationCoordinate().getLongitude()).isEqualTo(-9.1393);
    }

    @Test
    void routePlanWithoutCoordinateLoadsAndEditsNormally() {
        RoutePlan legacyRoutePlan = new RoutePlan();
        legacyRoutePlan.setStartLocation("Floripa");
        legacyRoutePlan.setDestination("Curitiba");
        // Sem coordinate: simula um registro criado antes de CPS-144.

        entityManager.persist(legacyRoutePlan);
        entityManager.flush();
        entityManager.clear();

        RoutePlan reloaded = entityManager.find(RoutePlan.class, legacyRoutePlan.getId());
        assertThat(reloaded.getStartLocationCoordinate()).isNull();
        assertThat(reloaded.getDestinationCoordinate()).isNull();

        reloaded.setStartLocation("Florianópolis, SC, Brasil");
        reloaded.setStartLocationCoordinate(new Coordinate(-27.5954, -48.5480));
        entityManager.flush();
        entityManager.clear();

        RoutePlan reeditedRoutePlan = entityManager.find(RoutePlan.class, legacyRoutePlan.getId());
        assertThat(reeditedRoutePlan.getStartLocationCoordinate().getLatitude()).isEqualTo(-27.5954);
    }

    @Test
    void interestPointPersistsCoordinate() {
        InterestPoint interestPoint = new InterestPoint();
        interestPoint.setName("Belem Tower");
        interestPoint.setCoordinate(new Coordinate(38.6916, -9.2160));

        entityManager.persist(interestPoint);
        entityManager.flush();
        entityManager.clear();

        InterestPoint reloaded = entityManager.find(InterestPoint.class, interestPoint.getId());
        assertThat(reloaded.getCoordinate().getLatitude()).isEqualTo(38.6916);
    }

    @Test
    void hostingPersistsCoordinate() {
        Hosting hosting = new Hosting();
        hosting.setName("Hotel Central");
        hosting.setAddress("Rua Principal, 100");
        hosting.setCoordinate(new Coordinate(-27.5954, -48.5480));

        entityManager.persist(hosting);
        entityManager.flush();
        entityManager.clear();

        Hosting reloaded = entityManager.find(Hosting.class, hosting.getId());
        assertThat(reloaded.getCoordinate().getLongitude()).isEqualTo(-48.5480);
    }

    // Airplane, Bus e RentalCar dividem a mesma tabela (SINGLE_TABLE) — este
    // teste também cobre que as colunas de coordenada de cada um não colidem.
    @Test
    void transportSubtypesPersistTheirOwnCoordinatesWithoutColumnCollision() {
        Airplane airplane = new Airplane();
        airplane.setDepartureAirport("GRU");
        airplane.setArrivalAirport("LIS");
        airplane.setDepartureAirportCoordinate(new Coordinate(-23.4356, -46.4731));
        airplane.setArrivalAirportCoordinate(new Coordinate(38.7813, -9.1359));

        Bus bus = new Bus();
        bus.setBusStationName("Terminal Tiete");
        bus.setBusStationCoordinate(new Coordinate(-23.5157, -46.6255));

        RentalCar rentalCar = new RentalCar();
        rentalCar.setPickupLocation("Aeroporto de Congonhas");
        rentalCar.setPickupLocationCoordinate(new Coordinate(-23.6261, -46.6564));

        entityManager.persist(airplane);
        entityManager.persist(bus);
        entityManager.persist(rentalCar);
        entityManager.flush();
        entityManager.clear();

        Airplane reloadedAirplane = entityManager.find(Airplane.class, airplane.getId());
        assertThat(reloadedAirplane.getDepartureAirportCoordinate().getLatitude()).isEqualTo(-23.4356);
        assertThat(reloadedAirplane.getArrivalAirportCoordinate().getLatitude()).isEqualTo(38.7813);

        Bus reloadedBus = entityManager.find(Bus.class, bus.getId());
        assertThat(reloadedBus.getBusStationCoordinate().getLongitude()).isEqualTo(-46.6255);

        RentalCar reloadedRentalCar = entityManager.find(RentalCar.class, rentalCar.getId());
        assertThat(reloadedRentalCar.getPickupLocation()).isEqualTo("Aeroporto de Congonhas");
        assertThat(reloadedRentalCar.getPickupLocationCoordinate().getLatitude()).isEqualTo(-23.6261);
    }
}
