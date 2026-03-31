package com.compass.compass_system;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TesteController {

    @GetMapping("/teste")
    public String responderTeste() {
        return "Backend do Compass System rodando com sucesso! Pode avisar o front-end que estamos online.";
    }
}
