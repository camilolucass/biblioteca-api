package com.lucas.bibliotecaapi.service;

import com.lucas.bibliotecaapi.dto.DisponibilidadeLivroDTO;
import com.lucas.bibliotecaapi.dto.LivroRequestDTO;
import com.lucas.bibliotecaapi.dto.LivroResponseDTO;
import com.lucas.bibliotecaapi.enums.StatusLivro;
import com.lucas.bibliotecaapi.exception.RecursoNaoEncontradoException;
import com.lucas.bibliotecaapi.exception.RegraNegocioException;
import com.lucas.bibliotecaapi.model.Livro;
import com.lucas.bibliotecaapi.repository.LivroRepository;
import java.time.LocalDateTime;
import java.time.Year;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LivroService {

    private final LivroRepository livroRepository;

    @Transactional
    public LivroResponseDTO cadastrar(LivroRequestDTO request) {
        validarAnoPublicacao(request.anoPublicacao());
        validarIsbnDisponivel(request.isbn());

        Livro livro = Livro.builder()
                .titulo(request.titulo().trim())
                .autor(request.autor().trim())
                .isbn(request.isbn().trim())
                .anoPublicacao(request.anoPublicacao())
                .categoria(trimToNull(request.categoria()))
                .status(StatusLivro.DISPONIVEL)
                .dataCadastro(LocalDateTime.now())
                .build();

        return toResponse(livroRepository.save(livro));
    }

    @Transactional(readOnly = true)
    public List<LivroResponseDTO> listarTodos() {
        return livroRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public LivroResponseDTO buscarPorId(Long id) {
        return toResponse(buscarLivro(id));
    }

    @Transactional(readOnly = true)
    public DisponibilidadeLivroDTO consultarDisponibilidade(Long id) {
        Livro livro = buscarLivro(id);
        boolean disponivel = livro.getStatus() == StatusLivro.DISPONIVEL;
        return new DisponibilidadeLivroDTO(livro.getId(), livro.getTitulo(), disponivel, livro.getStatus());
    }

    @Transactional
    public LivroResponseDTO atualizar(Long id, LivroRequestDTO request) {
        Livro livro = buscarLivro(id);
        validarAnoPublicacao(request.anoPublicacao());

        String novoIsbn = request.isbn().trim();
        if (!livro.getIsbn().equals(novoIsbn) && livroRepository.existsByIsbnAndIdNot(novoIsbn, id)) {
            throw new RegraNegocioException("ISBN ja cadastrado.");
        }

        livro.setTitulo(request.titulo().trim());
        livro.setAutor(request.autor().trim());
        livro.setIsbn(novoIsbn);
        livro.setAnoPublicacao(request.anoPublicacao());
        livro.setCategoria(trimToNull(request.categoria()));

        return toResponse(livroRepository.save(livro));
    }

    @Transactional
    public void remover(Long id) {
        Livro livro = buscarLivro(id);
        if (livro.getStatus() == StatusLivro.EMPRESTADO) {
            throw new RegraNegocioException("Nao e possivel excluir um livro emprestado.");
        }
        livroRepository.delete(livro);
    }

    private Livro buscarLivro(Long id) {
        return livroRepository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Livro nao encontrado."));
    }

    private void validarIsbnDisponivel(String isbn) {
        if (livroRepository.existsByIsbn(isbn.trim())) {
            throw new RegraNegocioException("ISBN ja cadastrado.");
        }
    }

    private void validarAnoPublicacao(Integer anoPublicacao) {
        if (anoPublicacao != null && anoPublicacao > Year.now().getValue()) {
            throw new RegraNegocioException("Ano de publicacao nao pode ser maior que o ano atual.");
        }
    }

    private LivroResponseDTO toResponse(Livro livro) {
        return new LivroResponseDTO(
                livro.getId(),
                livro.getTitulo(),
                livro.getAutor(),
                livro.getIsbn(),
                livro.getAnoPublicacao(),
                livro.getCategoria(),
                livro.getStatus(),
                livro.getDataCadastro()
        );
    }

    private String trimToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
