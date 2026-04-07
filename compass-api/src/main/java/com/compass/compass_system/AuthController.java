package com.compass.compass_system;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") // Isso libera para o front-end não ser bloqueado pelo navegador.
public class AuthController {

    @Autowired
    private UsuarioClienteRepository clienteRepository;

    // Rota para Cadastrar o Cliente
    @PostMapping("/cadastrar/cliente")
    public ResponseEntity<String> cadastrarCliente(@RequestBody UsuarioCliente novoCliente) {
        
        // Verifica se o e-mail já existe no banco antes de salvar
        Optional<UsuarioCliente> clienteExistente = clienteRepository.findByEmail(novoCliente.getEmail());
        if (clienteExistente.isPresent()) {
            return ResponseEntity.badRequest().body("Erro: Este e-mail já está cadastrado.");
        }

        // Salva o cliente no banco de dados 
        clienteRepository.save(novoCliente);
        
        return ResponseEntity.ok("Cliente cadastrado com sucesso no Compass System!");
    }
    
 // Classe auxiliar simples para receber os dados da tela de login
    public static class LoginRequest {
        public String email;
        public String senha;
    }

    // Rota para o Login do Cliente
    @PostMapping("/login/cliente")
    public ResponseEntity<String> loginCliente(@RequestBody LoginRequest login) {
        
        //  Busca o cliente no banco pelo email
        Optional<UsuarioCliente> clienteOpt = clienteRepository.findByEmail(login.email);
        
        //  Verifica se o cliente existe e se a senha digitada bate com a do banco
        if (clienteOpt.isPresent() && clienteOpt.get().getSenha().equals(login.senha)) {
            return ResponseEntity.ok("Login aprovado! Bem-vindo ao Compass System.");
        }
        
        //  Se algo estiver errado barra o acesso 
        return ResponseEntity.status(401).body("Erro: E-mail ou senha incorretos.");
    }
    
    
}