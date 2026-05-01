package com.br.ecommerce.loja.dto;

import java.util.List;

public record LojaResponse(String corPrimaria, String urlLogo, List<String> banners) {
}
