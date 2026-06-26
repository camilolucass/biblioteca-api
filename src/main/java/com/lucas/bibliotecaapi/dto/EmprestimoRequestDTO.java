package com.lucas.bibliotecaapi.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record EmprestimoRequestDTO(
        @NotNull(message = "ID do livro e obrigatorio.")
        Long livroId,

        @NotBlank(message = "Nome do usuario e obrigatorio.")
        String nomeUsuario,

        @Email(message = "E-mail do usuario deve ser valido.")
        String emailUsuario
) {
}
