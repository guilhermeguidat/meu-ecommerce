package com.br.ecommerce.loja.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import jakarta.persistence.ElementCollection;
import java.util.List;
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
    @ElementCollection
    private List<String> banners;
}
