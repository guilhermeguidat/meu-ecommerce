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

        boolean imagemLoginEnviada = lojaRequest.imagemLogin() != null && !lojaRequest.imagemLogin().isEmpty();

        if (imagemLoginEnviada) {
            if (!verificaSeArquivoEImagem(lojaRequest.imagemLogin())) throw new LogoInvalidaException("imagemLogin", "Arquivo da imagem de login deve ser uma imagem");
            try {
                bucketService.deleteImagemLogin(ID_DEFAULT);
                bucketService.upload(new BucketFile(bucketService.retornaNomeImagemLogin(ID_DEFAULT),
                        lojaRequest.imagemLogin().getInputStream(),
                        lojaRequest.imagemLogin().getContentType(),
                        lojaRequest.imagemLogin().getSize()));
            } catch (Exception e) {
                throw new LogoInvalidaException("imagemLogin", "Arquivo da imagem de login inválido!");
            }
        }

        List<Integer> indexesToKeep = new ArrayList<>();
        Loja lojaAtual = lojaRepository.findById(ID_DEFAULT).orElse(null);
        
        if (lojaAtual != null && lojaRequest.existingBanners() != null) {
            List<Integer> currentIndexes = parseBannerIndexes(lojaAtual.getBannersRaw());
            for (int idx : currentIndexes) {
                String urlForIdx = bucketService.getUrlBanner(ID_DEFAULT, idx).split("\\?")[0];
                boolean shouldKeep = false;
                for (String existingUrl : lojaRequest.existingBanners()) {
                    if (existingUrl.contains(urlForIdx)) {
                        shouldKeep = true;
                        break;
                    }
                }
                
                if (shouldKeep) {
                    indexesToKeep.add(idx);
                } else {
                    bucketService.deleteBanner(ID_DEFAULT, idx);
                }
            }
        } else if (lojaAtual != null && (lojaRequest.bannerFiles() == null || lojaRequest.bannerFiles().isEmpty())) {
             indexesToKeep.addAll(parseBannerIndexes(lojaAtual.getBannersRaw()));
        } else if (lojaAtual != null) {
            var oldIndexes = parseBannerIndexes(lojaAtual.getBannersRaw());
            for (int idx : oldIndexes) {
                bucketService.deleteBanner(ID_DEFAULT, idx);
            }
        }

        List<Integer> finalIndexes = new ArrayList<>(indexesToKeep);
        int nextIndex = finalIndexes.isEmpty() ? 0 : finalIndexes.stream().max(Integer::compare).orElse(-1) + 1;

        var bannerFiles = lojaRequest.bannerFiles();
        if (bannerFiles != null && !bannerFiles.isEmpty()) {
            for (MultipartFile bannerFile : bannerFiles) {
                if (bannerFile == null || bannerFile.isEmpty()) continue;
                if (!verificaSeArquivoEImagem(bannerFile)) throw new LogoInvalidaException("banner", "Arquivo deve ser imagem");
                
                try {
                    bucketService.upload(new BucketFile(
                            bucketService.retornaNomeBanner(ID_DEFAULT, nextIndex),
                            bannerFile.getInputStream(),
                            bannerFile.getContentType(),
                            bannerFile.getSize()
                    ));
                    finalIndexes.add(nextIndex);
                    nextIndex++;
                } catch (Exception e) {
                    throw new LogoInvalidaException("banner", "Erro ao fazer upload do banner");
                }
            }
        }

        String bannersRaw = finalIndexes.stream()
                .map(String::valueOf)
                .reduce((a, b) -> a + "," + b)
                .orElse("");

        Loja loja = new Loja(ID_DEFAULT, lojaRequest.corPrimaria(), lojaRequest.nome(), bannersRaw);
        lojaRepository.save(loja);

        String logoUrl = bucketService.getUrl(ID_DEFAULT);
        String imagemLoginUrl = bucketService.getUrlImagemLogin(ID_DEFAULT);

        return new LojaResponse(loja.getCorPrimaria(), loja.getNome(), logoUrl, imagemLoginUrl, recuperaUrlsBanners(bannersRaw));
    }

    public LojaResponse buscaConfig(){
        Loja loja = lojaRepository.findById(ID_DEFAULT).orElse(null);
        if (loja == null) {
            return new LojaResponse("#000000", "Meu Ecommerce", null, null, List.of());
        }
        var bannerUrls = recuperaUrlsBanners(loja.getBannersRaw());
        return new LojaResponse(loja.getCorPrimaria(), loja.getNome(), bucketService.getUrl(ID_DEFAULT), bucketService.getUrlImagemLogin(ID_DEFAULT), bannerUrls);
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
