package com.lucas.bibliotecaapi.controller;

import com.lucas.bibliotecaapi.dto.EmprestimoRequestDTO;
import com.lucas.bibliotecaapi.dto.EmprestimoResponseDTO;
import com.lucas.bibliotecaapi.service.EmprestimoService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/emprestimos")
@RequiredArgsConstructor
public class EmprestimoController {

    private final EmprestimoService emprestimoService;

    @PostMapping
    public ResponseEntity<EmprestimoResponseDTO> realizarEmprestimo(
            @Valid @RequestBody EmprestimoRequestDTO request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED).body(emprestimoService.realizarEmprestimo(request));
    }

    @GetMapping
    public ResponseEntity<List<EmprestimoResponseDTO>> listarTodos() {
        return ResponseEntity.ok(emprestimoService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<EmprestimoResponseDTO> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(emprestimoService.buscarPorId(id));
    }

    @GetMapping("/ativos")
    public ResponseEntity<List<EmprestimoResponseDTO>> listarAtivos() {
        return ResponseEntity.ok(emprestimoService.listarAtivos());
    }

    @GetMapping("/atrasados")
    public ResponseEntity<List<EmprestimoResponseDTO>> listarAtrasados() {
        return ResponseEntity.ok(emprestimoService.listarAtrasados());
    }

    @PutMapping("/{id}/devolucao")
    public ResponseEntity<EmprestimoResponseDTO> devolver(@PathVariable Long id) {
        return ResponseEntity.ok(emprestimoService.devolver(id));
    }
}
