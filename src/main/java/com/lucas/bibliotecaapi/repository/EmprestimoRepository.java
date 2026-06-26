package com.lucas.bibliotecaapi.repository;

import com.lucas.bibliotecaapi.enums.StatusEmprestimo;
import com.lucas.bibliotecaapi.model.Emprestimo;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EmprestimoRepository extends JpaRepository<Emprestimo, Long> {
    List<Emprestimo> findByStatus(StatusEmprestimo status);

    @Query("""
            select e from Emprestimo e
            where e.status = com.lucas.bibliotecaapi.enums.StatusEmprestimo.ATIVO
            and e.dataPrevistaDevolucao < :dataAtual
            """)
    List<Emprestimo> findAtrasados(@Param("dataAtual") LocalDate dataAtual);
}
