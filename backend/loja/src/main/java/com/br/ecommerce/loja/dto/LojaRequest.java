package com.br.ecommerce.loja.dto;

import org.springframework.web.multipart.MultipartFile;
import java.util.List;

public record LojaRequest(String corPrimaria, String nome, MultipartFile logo, MultipartFile imagemLogin, List<MultipartFile> bannerFiles, List<String> existingBanners) {
}
