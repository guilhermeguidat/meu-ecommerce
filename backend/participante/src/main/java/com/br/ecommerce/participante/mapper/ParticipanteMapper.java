package com.br.ecommerce.participante.mapper;

import com.br.ecommerce.participante.dto.ParticipanteRequest;
import com.br.ecommerce.participante.dto.ParticipanteResponse;
import com.br.ecommerce.participante.model.Participante;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ParticipanteMapper {

    @org.mapstruct.Mapping(target = "name", source = "nome")
    ParticipanteResponse map(Participante participante);
    @org.mapstruct.Mapping(target = "id", ignore = true)
    Participante map(ParticipanteRequest participanteRequest);
}
