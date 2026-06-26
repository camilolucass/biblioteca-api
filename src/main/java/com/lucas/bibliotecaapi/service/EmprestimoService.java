package com.lucas.bibliotecaapi.service;

import com.lucas.bibliotecaapi.dto.EmprestimoRequestDTO;
import com.lucas.bibliotecaapi.dto.EmprestimoResponseDTO;
import com.lucas.bibliotecaapi.enums.StatusEmprestimo;
import com.lucas.bibliotecaapi.enums.StatusLivro;
import com.lucas.bibliotecaapi.exception.RecursoNaoEncontradoException;
import com.lucas.bibliotecaapi.exception.RegraNegocioException;
import com.lucas.bibliotecaapi.model.Emprestimo;
import com.lucas.bibliotecaapi.model.Livro;
import com.lucas.bibliotecaapi.repository.EmprestimoRepository;
import com.lucas.bibliotecaapi.repository.LivroRepository;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class EmprestimoService {

    private static final int DIAS_PARA_DEVOLUCAO = 7;

    private final EmprestimoRepository emprestimoRepository;
    private final LivroRepository livroRepository;

    @Transactional
    public EmprestimoResponseDTO realizarEmprestimo(EmprestimoRequestDTO request) {
        Livro livro = livroRepository.findById(request.livroId())
                .orElseThrow(() -> new RecursoNaoEncontradoException("Livro nao encontrado."));

        if (livro.getStatus() != StatusLivro.DISPONIVEL) {
            throw new RegraNegocioException("Livro nao esta disponivel para emprestimo.");
        }

        LocalDate dataEmprestimo = LocalDate.now();
        Emprestimo emprestimo = Emprestimo.builder()
                .livro(livro)
                .nomeUsuario(request.nomeUsuario().trim())
                .emailUsuario(trimToNull(request.emailUsuario()))
                .dataEmprestimo(dataEmprestimo)
                .dataPrevistaDevolucao(dataEmprestimo.plusDays(DIAS_PARA_DEVOLUCAO))
                .status(StatusEmprestimo.ATIVO)
                .build();

        livro.setStatus(StatusLivro.EMPRESTADO);
        return toResponse(emprestimoRepository.save(emprestimo));
    }

    @Transactional(readOnly = true)
    public List<EmprestimoResponseDTO> listarTodos() {
        return emprestimoRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public EmprestimoResponseDTO buscarPorId(Long id) {
        return toResponse(buscarEmprestimo(id));
    }

    @Transactional(readOnly = true)
    public List<EmprestimoResponseDTO> listarAtivos() {
        return emprestimoRepository.findByStatus(StatusEmprestimo.ATIVO)
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<EmprestimoResponseDTO> listarAtrasados() {
        return emprestimoRepository.findAtrasados(LocalDate.now())
                .stream()
                .map(emprestimo -> toResponse(emprestimo, StatusEmprestimo.ATRASADO))
                .toList();
    }

    @Transactional
    public EmprestimoResponseDTO devolver(Long id) {
        Emprestimo emprestimo = buscarEmprestimo(id);
        StatusEmprestimo statusAtual = statusEfetivo(emprestimo);

        if (statusAtual == StatusEmprestimo.FINALIZADO) {
            throw new RegraNegocioException("Este emprestimo ja foi finalizado.");
        }

        if (statusAtual != StatusEmprestimo.ATIVO && statusAtual != StatusEmprestimo.ATRASADO) {
            throw new RegraNegocioException("Emprestimo deve estar ativo para ser devolvido.");
        }

        Livro livro = emprestimo.getLivro();
        if (livro.getStatus() != StatusLivro.EMPRESTADO) {
            throw new RegraNegocioException("Livro deve estar emprestado para ser devolvido.");
        }

        emprestimo.setDataDevolucao(LocalDate.now());
        emprestimo.setStatus(StatusEmprestimo.FINALIZADO);
        livro.setStatus(StatusLivro.DISPONIVEL);

        return toResponse(emprestimoRepository.save(emprestimo));
    }

    private Emprestimo buscarEmprestimo(Long id) {
        return emprestimoRepository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Emprestimo nao encontrado."));
    }

    private EmprestimoResponseDTO toResponse(Emprestimo emprestimo) {
        return toResponse(emprestimo, statusEfetivo(emprestimo));
    }

    private EmprestimoResponseDTO toResponse(Emprestimo emprestimo, StatusEmprestimo status) {
        Livro livro = emprestimo.getLivro();
        return new EmprestimoResponseDTO(
                emprestimo.getId(),
                livro.getId(),
                livro.getTitulo(),
                emprestimo.getNomeUsuario(),
                emprestimo.getEmailUsuario(),
                emprestimo.getDataEmprestimo(),
                emprestimo.getDataPrevistaDevolucao(),
                emprestimo.getDataDevolucao(),
                status
        );
    }

    private StatusEmprestimo statusEfetivo(Emprestimo emprestimo) {
        if (emprestimo.getStatus() == StatusEmprestimo.ATIVO
                && emprestimo.getDataPrevistaDevolucao().isBefore(LocalDate.now())) {
            return StatusEmprestimo.ATRASADO;
        }
        return emprestimo.getStatus();
    }

    private String trimToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
