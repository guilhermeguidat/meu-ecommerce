package com.br.ecommerce.loja.dto;



import java.io.InputStream;

public record BucketFile(String name, InputStream is, String type, long size) {
}
