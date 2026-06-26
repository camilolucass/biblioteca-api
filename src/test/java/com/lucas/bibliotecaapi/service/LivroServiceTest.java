package com.lucas.bibliotecaapi.service;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.lucas.bibliotecaapi.dto.LivroRequestDTO;
import com.lucas.bibliotecaapi.exception.RegraNegocioException;
import com.lucas.bibliotecaapi.repository.LivroRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class LivroServiceTest {

    @Mock
    private LivroRepository livroRepository;

    @InjectMocks
    private LivroService livroService;

    @Test
    void naoPermitirCadastrarIsbnDuplicado() {
        LivroRequestDTO request = new LivroRequestDTO(
                "Clean Code",
                "Robert C. Martin",
                "9780132350884",
                2008,
                "Programacao"
        );

        when(livroRepository.existsByIsbn("9780132350884")).thenReturn(true);

        assertThatThrownBy(() -> livroService.cadastrar(request))
                .isInstanceOf(RegraNegocioException.class)
                .hasMessage("ISBN ja cadastrado.");

        verify(livroRepository).existsByIsbn("9780132350884");
    }
}
