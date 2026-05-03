package com.br.ecommerce.loja.service;

import com.br.ecommerce.loja.dto.BucketFile;
import com.br.ecommerce.loja.dto.LojaRequest;
import com.br.ecommerce.loja.dto.LojaResponse;
import com.br.ecommerce.loja.exception.exception.CorInvalidaException;
import com.br.ecommerce.loja.exception.exception.LogoInvalidaException;
import com.br.ecommerce.loja.model.Loja;
import com.br.ecommerce.loja.repository.LojaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class LojaService {

    private static final String ID_DEFAULT = "default-config";
    private static final Pattern HEX_COLOR_PATTERN = Pattern.compile("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");

    private final LojaRepository lojaRepository;
    private final BucketService bucketService;

    public LojaResponse alteraPersonalizacao(LojaRequest lojaRequest){
        if(!codigoHexadecimal(lojaRequest.corPrimaria())) throw new CorInvalidaException("corPrimaria", "Cor não está no modelo hexadecimal!");

        boolean logoEnviada = lojaRequest.logo() != null && !lojaRequest.logo().isEmpty();

        if (logoEnviada) {
            if (!verificaSeArquivoEImagem(lojaRequest.logo())) throw new LogoInvalidaException("logo", "Arquivo da logo deve ser uma imagem");
            try {
                bucketService.delete(ID_DEFAULT);
                bucketService.upload(new BucketFile(bucketService.retornaNomeLogo(ID_DEFAULT),
                        lojaRequest.logo().getInputStream(),
                        lojaRequest.logo().getContentType(),
                        lojaRequest.logo().getSize()));
            } catch (Exception e) {
                throw new LogoInvalidaException("logo", "Arquivo da logo inválido!");
            }
        }

        List<String> bannerUrls = new ArrayList<>();
        var bannerFiles = lojaRequest.bannerFiles();

        if (bannerFiles != null && !bannerFiles.isEmpty()) {
            // Remove banners antigos antes de fazer upload dos novos
            Loja lojaAtual = lojaRepository.findByid(ID_DEFAULT);
            if (lojaAtual != null) {
                var oldIndexes = parseBannerIndexes(lojaAtual.getBannersRaw());
                for (int idx : oldIndexes) {
                    bucketService.deleteBanner(ID_DEFAULT, idx);
                }
            }

            for (int i = 0; i < bannerFiles.size(); i++) {
                var bannerFile = bannerFiles.get(i);
                if (bannerFile == null || bannerFile.isEmpty()) {
                    continue;
                }
                if (!verificaSeArquivoEImagem(bannerFile)) {
                    throw new LogoInvalidaException("bannerFiles[" + i + "]", "Banner deve ser uma imagem");
                }
                try {
                    bucketService.upload(new BucketFile(
                            bucketService.retornaNomeBanner(ID_DEFAULT, i),
                            bannerFile.getInputStream(),
                            bannerFile.getContentType(),
                            bannerFile.getSize()
                    ));
                    bannerUrls.add(bucketService.getUrlBanner(ID_DEFAULT, i));
                } catch (Exception e) {
                    throw new LogoInvalidaException("bannerFiles[" + i + "]", "Erro ao fazer upload do banner " + i);
                }
            }
        }

        // Salva contagem de banners como índices CSV (0,1,2,...) para recuperar as URLs depois
        Loja lojaParaContagem = lojaRepository.findByid(ID_DEFAULT);
        int bannerCount = (bannerFiles != null) ? (int) bannerFiles.stream().filter(f -> f != null && !f.isEmpty()).count() : -1;
        String bannersRaw = bannerCount >= 0
                ? buildBannerIndexesRaw(bannerCount)
                : (lojaParaContagem != null ? lojaParaContagem.getBannersRaw() : "");

        Loja loja = new Loja(ID_DEFAULT, lojaRequest.corPrimaria(), bannersRaw);
        lojaRepository.save(loja);

        String logoUrl = logoEnviada ? bucketService.getUrl(ID_DEFAULT) : null;

        if (bannerFiles != null && !bannerFiles.isEmpty()) {
            return new LojaResponse(loja.getCorPrimaria(), logoUrl, bannerUrls);
        }
        return new LojaResponse(loja.getCorPrimaria(), logoUrl, recuperaUrlsBanners(bannersRaw));
    }

    public LojaResponse buscaConfig(){
        Loja loja = lojaRepository.findByid(ID_DEFAULT);
        if (loja == null) {
            return new LojaResponse("#000000", null, List.of());
        }
        var bannerUrls = recuperaUrlsBanners(loja.getBannersRaw());
        return new LojaResponse(loja.getCorPrimaria(), bucketService.getUrl(ID_DEFAULT), bannerUrls);
    }

    private List<String> recuperaUrlsBanners(String bannersRaw) {
        var indexes = parseBannerIndexes(bannersRaw);
        List<String> urls = new ArrayList<>();
        for (int idx : indexes) {
            var url = bucketService.getUrlBanner(ID_DEFAULT, idx);
            if (url != null && !url.isBlank()) {
                urls.add(url);
            }
        }
        return urls;
    }

    private List<Integer> parseBannerIndexes(String bannersRaw) {
        if (bannersRaw == null || bannersRaw.isBlank()) {
            return List.of();
        }
        try {
            return Arrays.stream(bannersRaw.split(","))
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(Integer::parseInt)
                    .toList();
        } catch (NumberFormatException e) {
            return List.of();
        }
    }

    private String buildBannerIndexesRaw(int count) {
        if (count == 0) {
            return "";
        }
        var sb = new StringBuilder();
        for (int i = 0; i < count; i++) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(i);
        }
        return sb.toString();
    }

    private boolean verificaSeArquivoEImagem(MultipartFile arquivo){
        if (arquivo == null || arquivo.isEmpty()) {
            return false;
        }
        var contentType = arquivo.getContentType();
        // Aceita image/*, ou octet-stream como fallback (alguns clientes não enviam o tipo correto)
        return contentType != null && (contentType.startsWith("image/") || contentType.equals("application/octet-stream"));
    }

    private boolean codigoHexadecimal(String value) { return value != null && HEX_COLOR_PATTERN.matcher(value).matches(); }
}
