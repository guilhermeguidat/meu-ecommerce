package com.br.ecommerce.loja.dto;

import java.util.List;

public record LojaResponse(String corPrimaria, String nome, String urlLogo, String urlImagemLogin, List<String> banners) {
}
