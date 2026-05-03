package com.br.ecommerce.produto.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;
import java.util.ArrayList;

/**
 * DTO de request do produto. Usa classe POJO com Lombok (não record) para permitir
 * o binding correto do Spring @ModelAttribute com multipart/form-data e listas aninhadas.
 */
@Getter
@Setter
@NoArgsConstructor
public class ProdutoRequest {
    private Long id;
    private MultipartFile imagem;
    private String descricao;
    private BigDecimal valorUnitario;
    private Integer quantidade;
    private List<ProdutoVariacaoDto> variacoes = new ArrayList<>();
    private String categoria;
}
