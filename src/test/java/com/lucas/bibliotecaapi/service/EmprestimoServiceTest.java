package com.lucas.bibliotecaapi.service;

import static java.time.temporal.ChronoUnit.DAYS;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.lucas.bibliotecaapi.dto.EmprestimoRequestDTO;
import com.lucas.bibliotecaapi.dto.EmprestimoResponseDTO;
import com.lucas.bibliotecaapi.enums.StatusEmprestimo;
import com.lucas.bibliotecaapi.enums.StatusLivro;
import com.lucas.bibliotecaapi.exception.RegraNegocioException;
import com.lucas.bibliotecaapi.model.Emprestimo;
import com.lucas.bibliotecaapi.model.Livro;
import com.lucas.bibliotecaapi.repository.EmprestimoRepository;
import com.lucas.bibliotecaapi.repository.LivroRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class EmprestimoServiceTest {

    @Mock
    private EmprestimoRepository emprestimoRepository;

    @Mock
    private LivroRepository livroRepository;

    @InjectMocks
    private EmprestimoService emprestimoService;

    @Test
    void naoPermitirEmprestarLivroIndisponivel() {
        Livro livro = livroBase();
        livro.setStatus(StatusLivro.EMPRESTADO);
        EmprestimoRequestDTO request = requestEmprestimo();

        when(livroRepository.findById(1L)).thenReturn(Optional.of(livro));

        assertThatThrownBy(() -> emprestimoService.realizarEmprestimo(request))
                .isInstanceOf(RegraNegocioException.class)
                .hasMessage("Livro nao esta disponivel para emprestimo.");

        verifyNoInteractions(emprestimoRepository);
    }

    @Test
    void emprestarLivroDisponivelComSucesso() {
        Livro livro = livroBase();
        EmprestimoRequestDTO request = requestEmprestimo();

        when(livroRepository.findById(1L)).thenReturn(Optional.of(livro));
        when(emprestimoRepository.save(any(Emprestimo.class))).thenAnswer(invocation -> {
            Emprestimo emprestimo = invocation.getArgument(0);
            emprestimo.setId(1L);
            return emprestimo;
        });

        EmprestimoResponseDTO response = emprestimoService.realizarEmprestimo(request);

        assertThat(livro.getStatus()).isEqualTo(StatusLivro.EMPRESTADO);
        assertThat(response.status()).isEqualTo(StatusEmprestimo.ATIVO);
        assertThat(response.livroId()).isEqualTo(1L);
        assertThat(DAYS.between(response.dataEmprestimo(), response.dataPrevistaDevolucao())).isEqualTo(7);
    }

    @Test
    void devolverLivroComSucesso() {
        Livro livro = livroBase();
        livro.setStatus(StatusLivro.EMPRESTADO);
        Emprestimo emprestimo = emprestimoAtivo(livro);

        when(emprestimoRepository.findById(1L)).thenReturn(Optional.of(emprestimo));
        when(emprestimoRepository.save(any(Emprestimo.class))).thenAnswer(invocation -> invocation.getArgument(0));

        EmprestimoResponseDTO response = emprestimoService.devolver(1L);

        assertThat(livro.getStatus()).isEqualTo(StatusLivro.DISPONIVEL);
        assertThat(response.status()).isEqualTo(StatusEmprestimo.FINALIZADO);
        assertThat(response.dataDevolucao()).isEqualTo(LocalDate.now());
    }

    @Test
    void naoPermitirDevolverEmprestimoJaFinalizado() {
        Livro livro = livroBase();
        livro.setStatus(StatusLivro.DISPONIVEL);
        Emprestimo emprestimo = emprestimoAtivo(livro);
        emprestimo.setStatus(StatusEmprestimo.FINALIZADO);

        when(emprestimoRepository.findById(1L)).thenReturn(Optional.of(emprestimo));

        assertThatThrownBy(() -> emprestimoService.devolver(1L))
                .isInstanceOf(RegraNegocioException.class)
                .hasMessage("Este emprestimo ja foi finalizado.");
    }

    private Livro livroBase() {
        return Livro.builder()
                .id(1L)
                .titulo("Clean Code")
                .autor("Robert C. Martin")
                .isbn("9780132350884")
                .anoPublicacao(2008)
                .categoria("Programacao")
                .status(StatusLivro.DISPONIVEL)
                .dataCadastro(LocalDateTime.now())
                .build();
    }

    private Emprestimo emprestimoAtivo(Livro livro) {
        LocalDate hoje = LocalDate.now();
        return Emprestimo.builder()
                .id(1L)
                .livro(livro)
                .nomeUsuario("Lucas Camilo")
                .emailUsuario("lucas@email.com")
                .dataEmprestimo(hoje)
                .dataPrevistaDevolucao(hoje.plusDays(7))
                .status(StatusEmprestimo.ATIVO)
                .build();
    }

    private EmprestimoRequestDTO requestEmprestimo() {
        return new EmprestimoRequestDTO(1L, "Lucas Camilo", "lucas@email.com");
    }
}
