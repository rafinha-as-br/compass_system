package com.compass.compass_system.travel;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface TravelRepository extends JpaRepository<Travel, String> {
    List<Travel> findByCompany_Id(Long companyId);
    List<Travel> findByClientNameAndCompany_Id(String clientName, Long companyId);
    Optional<Travel> findByIdAndCompany_Id(String id, Long companyId);
    long countByCompany_Id(Long companyId);
    long countByCompany_IdAndItineraryIsNotNull(Long companyId);
}
