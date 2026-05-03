package com.br.ecommerce.loja.service;

import com.br.ecommerce.loja.config.props.MinioProps;
import com.br.ecommerce.loja.dto.BucketFile;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
@RequiredArgsConstructor
public class BucketService {

    private final MinioClient minioClient;
    private final MinioProps minioProps;

    public void upload(BucketFile bucketFile) throws Exception{
        var object = PutObjectArgs
                .builder()
                .bucket(minioProps.getBucketName())
                .object(bucketFile.name())
                .stream(bucketFile.is(), bucketFile.size(), -1)
                .contentType(bucketFile.type())
                .build();
        minioClient.putObject(object);
    }

    public String getUrl(String idLoja){
        return getUrlByObjectName(retornaNomeLogo(idLoja));
    }

    public String getUrlImagemLogin(String idLoja){
        return getUrlByObjectName(retornaNomeImagemLogin(idLoja));
    }

    public String getUrlBanner(String idLoja, int index){
        return getUrlByObjectName(retornaNomeBanner(idLoja, index));
    }

    public void delete(String idLoja) {
        deleteByObjectName(retornaNomeLogo(idLoja));
    }

    public void deleteImagemLogin(String idLoja) {
        deleteByObjectName(retornaNomeImagemLogin(idLoja));
    }

    public void deleteBanner(String idLoja, int index) {
        deleteByObjectName(retornaNomeBanner(idLoja, index));
    }

    public String retornaNomeLogo(String idLoja) {
        return String.format("logo-%s", idLoja);
    }

    public String retornaNomeImagemLogin(String idLoja) {
        return String.format("login-%s", idLoja);
    }

    public String retornaNomeBanner(String idLoja, int index) {
        return String.format("banner-%s-%d", idLoja, index);
    }

    private String getUrlByObjectName(String objectName){
        try{
            var object = GetPresignedObjectUrlArgs
                    .builder()
                    .method(Method.GET)
                    .bucket(minioProps.getBucketName())
                    .object(objectName)
                    .expiry(1, TimeUnit.DAYS)
                    .build();

            return minioClient.getPresignedObjectUrl(object);
        } catch(Exception e){
            return "";
        }
    }

    private void deleteByObjectName(String objectName) {
        try {
            var args = RemoveObjectArgs
                    .builder()
                    .bucket(minioProps.getBucketName())
                    .object(objectName)
                    .build();

            minioClient.removeObject(args);
        } catch (Exception ignored) {}
    }
}

