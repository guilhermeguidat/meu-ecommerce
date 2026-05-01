package com.ecommerce.pedido.mapper;

import com.ecommerce.pedido.dto.PagamentoPedidoRequest;
import com.ecommerce.pedido.dto.PagamentoResponse;

import com.ecommerce.pedido.model.PagamentoPedido;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface PagamentoMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "pedido", ignore = true)
    @Mapping(target = "valorPagamento", source = "valorAPagar")
    @Mapping(target = "statusPagamento", expression = "java(StatusPagamento.PENDENTE)")
    @Mapping(target = "mercadoPagoId", ignore = true)
    @Mapping(target = "observacaoStatus", ignore = true)
    PagamentoPedido map(PagamentoPedidoRequest request);

    @Mapping(target = "qrCodePix", ignore = true)
    @Mapping(target = "qrCodeBase64Pix", ignore = true)
    PagamentoResponse map(PagamentoPedido entity);
}
