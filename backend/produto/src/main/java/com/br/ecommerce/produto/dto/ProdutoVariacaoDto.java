package com.br.ecommerce.produto.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * DTO de variação do produto. Usa POJO com Lombok (não record) para permitir
 * o binding correto do Spring @ModelAttribute com listas aninhadas em multipart/form-data.
 */
@Getter
@Setter
@NoArgsConstructor
public class ProdutoVariacaoDto {
    private Long id;
    private String tamanho;
    private String cor;
    private Integer quantidade;
}
