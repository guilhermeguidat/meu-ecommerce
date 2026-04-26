package com.br.ecommerce.produto.exception.exceptions;

import lombok.Getter;

@Getter
public class ProdutoNaoEcontradoException extends RuntimeException {

    private String campo;
    private String mensagem;

    public ProdutoNaoEcontradoException(String campo, String mensagem) {
        this.campo = campo;
        this.mensagem = mensagem;
    }
}
