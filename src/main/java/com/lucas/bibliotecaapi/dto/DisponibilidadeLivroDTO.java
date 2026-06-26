package com.lucas.bibliotecaapi.dto;

import com.lucas.bibliotecaapi.enums.StatusLivro;

public record DisponibilidadeLivroDTO(
        Long livroId,
        String titulo,
        boolean disponivel,
        StatusLivro status
) {
}
