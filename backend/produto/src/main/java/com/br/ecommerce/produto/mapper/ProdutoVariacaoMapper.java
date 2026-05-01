package com.br.ecommerce.produto.mapper;

import com.br.ecommerce.produto.dto.ProdutoVariacaoDto;
import com.br.ecommerce.produto.model.ProdutoVariacao;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProdutoVariacaoMapper {

    ProdutoVariacaoDto map(ProdutoVariacao entity);

    @Mapping(target = "produto", ignore = true)
    ProdutoVariacao map(ProdutoVariacaoDto dto);
}