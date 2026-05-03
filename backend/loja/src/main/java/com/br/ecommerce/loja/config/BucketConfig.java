package com.br.ecommerce.loja.config;

import com.br.ecommerce.loja.config.props.MinioProps;
import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Slf4j
@Configuration
public class BucketConfig {

    @Autowired
    MinioProps minioProps;

    @Bean
    public MinioClient bucketClient(){
        var client = MinioClient.builder()
                .endpoint(minioProps.getUrl())
                .credentials(minioProps.getAccessKey(), minioProps.getSecretKey())
                .build();

        try {
            var exists = client.bucketExists(BucketExistsArgs.builder().bucket(minioProps.getBucketName()).build());
            if (!exists) {
                client.makeBucket(MakeBucketArgs.builder().bucket(minioProps.getBucketName()).build());
                log.info("Bucket '{}' criado com sucesso.", minioProps.getBucketName());
            }
        } catch (Exception e) {
            log.warn("Não foi possível verificar/criar o bucket '{}': {}", minioProps.getBucketName(), e.getMessage());
        }

        return client;
    }
}
