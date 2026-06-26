package com.lucas.bibliotecaapi.dto;

import com.lucas.bibliotecaapi.enums.StatusEmprestimo;
import java.time.LocalDate;

public record EmprestimoResponseDTO(
        Long id,
        Long livroId,
        String livro,
        String nomeUsuario,
        String emailUsuario,
        LocalDate dataEmprestimo,
        LocalDate dataPrevistaDevolucao,
        LocalDate dataDevolucao,
        StatusEmprestimo status
) {
}
