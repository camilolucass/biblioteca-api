package com.lucas.bibliotecaapi.dto;

import com.lucas.bibliotecaapi.enums.StatusLivro;
import java.time.LocalDateTime;

public record LivroResponseDTO(
        Long id,
        String titulo,
        String autor,
        String isbn,
        Integer anoPublicacao,
        String categoria,
        StatusLivro status,
        LocalDateTime dataCadastro
) {
}
