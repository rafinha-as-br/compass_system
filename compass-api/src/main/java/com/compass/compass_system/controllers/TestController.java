package com.compass.compass_system.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/teste")
    public String testResponse() {
        return "Backend do Compass System rodando com sucesso! Pode avisar o front-end que estamos online.";
    }
}
