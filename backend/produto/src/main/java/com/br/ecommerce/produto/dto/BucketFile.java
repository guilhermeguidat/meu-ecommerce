package com.br.ecommerce.produto.dto;



import java.io.InputStream;

public record BucketFile(String name, InputStream is, String type, long size) {
}
