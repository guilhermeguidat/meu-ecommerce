package com.br.ecommerce.loja.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "loja")
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
public class Loja {

    @Id
    private String id;
    private String corPrimaria;
    private String nome;

    @Column(columnDefinition = "TEXT")
    private String bannersRaw;
}
