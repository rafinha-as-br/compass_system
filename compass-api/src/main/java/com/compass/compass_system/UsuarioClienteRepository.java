package com.compass.compass_system;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface UsuarioClienteRepository extends JpaRepository<UsuarioCliente, Long> {

    Optional<UsuarioCliente> findByEmail(String email);

}