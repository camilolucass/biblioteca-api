package com.lucas.bibliotecaapi.dto;

import jakarta.validation.constraints.NotBlank;

public record LivroRequestDTO(
        @NotBlank(message = "Titulo e obrigatorio.")
        String titulo,

        @NotBlank(message = "Autor e obrigatorio.")
        String autor,

        @NotBlank(message = "ISBN e obrigatorio.")
        String isbn,

        Integer anoPublicacao,

        String categoria
) {
}
