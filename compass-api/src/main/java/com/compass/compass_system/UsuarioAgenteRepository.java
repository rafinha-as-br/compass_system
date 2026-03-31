package com.compass.compass_system;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UsuarioAgenteRepository extends JpaRepository<UsuarioAgente, Long> {

    // Usado para verificar o login do agente na página web Travel Matrix.
    Optional<UsuarioAgente> findByEmail(String email);

}